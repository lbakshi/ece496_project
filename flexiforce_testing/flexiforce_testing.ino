#include <bluefruit.h>
//Service UUID is 0x181D
//Weight measurement characteristic UUID is 0x2A9D 
//Weight Scale Feature characteristic UUID is 0x2A9E
float cf = 19.5;
int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
int toe = 0;
int ball = 0;
int heel = 0;
float vout;
unsigned long time = 0; 
BLEService weight_service = BLEService(0x181D);
BLECharacteristic weight_measurement_characteristic = BLECharacteristic(0x2A9D);
BLECharacteristic weight_scale_feature = BLECharacteristic(0x2A9E);
BLEDis bledis; // Device information service helper class instance???
BLEBas blebas; // battery service helper class instance


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(fs1, INPUT);
  pinMode(fs2, INPUT);
  pinMode(fs3, INPUT);
  
  // Initialize the Bluefruit module
  Bluefruit.begin();
  
  // Set the advertised device name 
  Bluefruit.setName("StrikeSock Bluefruit");
  
  // Set the connect/disconnect callback handlers 
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);
  
  // Configure and start the device information service 
  bledis.setManufacturer("Adafruit Industries");
  bledis.setModel("Bluefruit Feather52");
  bledis.begin();
  
  // Start the BLE battery service and set it to 100%
  blebas.begin();
  blebas.write(100);

  // Set up the weight scale service 
  setUpWeight();
  
  // Set up the advertisign packets
  startAdv();
}

void setUpWeight(void){
  // Configure the service
  weight_service.begin();

  // Configure the weight measurement characteristic - Indicate 
  weight_measurement_characteristic.setProperties(CHR_PROPS_INDICATE);
  weight_measurement_characteristic.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  // there are probably some other things to configure but I am not sure ****
  weight_measurement_characteristic.begin();

  // Configure the weight scale feature - Read
  weight_scale_feature.setProperties(CHR_PROPS_READ);
  weight_scale_feature.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  // there are probably some other things to configure but I am not sure ****
  weight_scale_feature.begin();
  
}

void startAdv(void){
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE); //not sure what this means
  Bluefruit.Advertising.addTxPower();

  // Include Weight Service UUID
  Bluefruit.Advertising.addService(weight_service);

  // Include name
  Bluefruit.Advertising.addName(); // should there be a name here?

  /* Start Advertising
   * - Enable auto advertising if disconnected
   * - Interval:  fast mode = 20 ms, slow mode = 152.5 ms
   * - Timeout for fast mode is 30 seconds
   * - Start(timeout) with timeout = 0 will advertise forever (until connected)
   * 
   * For recommended advertising interval
   * https://developer.apple.com/library/content/qa/qa1931/_index.html   
   */
  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);                // 0 = Don't stop advertising after n seconds
  // can change values around if we want to advertise differently
  
}

void connect_callback(uint16_t conn_handle)
{
  
}
 
/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  
}

void loop() {
  // put your main code here, to run repeatedly:
  //Serial.print("Time: ");
  //time = millis();
  //Serial.println(time); //prints time since program started
  
  toe = analogRead(fs1);
  ball = analogRead(fs2);
  heel = analogRead(fs3);
  //vout1 = (fs1Data * 5.0) / 1023.0;
  //vout = vout *cf;
  if(toe > 10){
     Serial.print("Flexi Force sensor 1: ");
     Serial.print(toe);
     Serial.println("");
  }
  if(ball > 10){
     Serial.print("Flexi Force sensor 2: ");
     Serial.print(ball);
     Serial.println("");
  }
  if(heel > 10){
     Serial.print("Flexi Force sensor 3: ");
     Serial.print(heel);
     Serial.println("");
  }
 
  delay(100);

}
