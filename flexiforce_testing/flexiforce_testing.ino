#include <bluefruit.h>
//Service UUID is 0x181D
//Weight measurement characteristic UUID is 0x2A9D 
//Weight Scale Feature characteristic UUID is 0x2A9E

// Online generated UUIDs in case we want to implement our own service and characteristics 
//dea53006-ea01-4939-a384-1573aae78dca
//e7725f91-84af-4527-b045-6f7d3cc1b67d
//ab77fad9-d27b-4c46-8b44-771be5c01072
//1c005070-4bbd-428e-86bd-0287d7775a1e
//6f242ade-5fa3-4185-9c2d-2ff865c2e850
float cf = 19.5;
int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
int toe = 0;
int ball = 0;
int heel = 0;
unsigned long time = 0; 
BLEService weight_service = BLEService(0x181D);
BLECharacteristic weight_measurement_characteristic = BLECharacteristic(0x2A9D);
BLECharacteristic weight_scale_feature = BLECharacteristic(0x2A9E);
BLEDis bledis; // Device information service helper class instance
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

  // Set up the advertisign packets
  startAdv();

  // Set up the weight scale service 
  setUpWeight();
  
}

void setUpWeight(void){
  // Configure the service
  weight_service.begin();

  // Configure the weight measurement characteristic - Indicate BUT i want to change it to notify
  weight_measurement_characteristic.setProperties(CHR_PROPS_INDICATE);
  weight_measurement_characteristic.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  weight_measurement_characteristic.setMaxLen(2);
  weight_measurement_characteristic.begin();
  //weight_measurement_characteristic.indicate32(toe); // should notify central on the change of this variable

  // Configure the weight scale feature - Read
  weight_scale_feature.setProperties(CHR_PROPS_READ);
  weight_scale_feature.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  weight_scale_feature.setFixedLen(2);
  weight_scale_feature.begin();  
  weight_scale_feature.write32(toe); // should hold the new value of this variable

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
  // Get the reference to current connection
  BLEConnection* connection = Bluefruit.Connection(conn_handle);
 
  char central_name[32] = { 0 };
  connection->getPeerName(central_name, sizeof(central_name));
 
  Serial.print("Connected to ");
  Serial.println(central_name);
  
}
 
/**
 * Callback invoked when a connection is dropped
 * @param conn_handle connection where this event happens
 * @param reason is a BLE_HCI_STATUS_CODE which can be found in ble_hci.h
 */
void disconnect_callback(uint16_t conn_handle, uint8_t reason)
{
  (void) conn_handle;
  (void) reason;
 
  Serial.print("Disconnected, reason = 0x"); Serial.println(reason, HEX);
  Serial.println("Advertising!");
  
}

void loop() {
  toe = analogRead(fs1);
  ball = analogRead(fs2);
  heel = analogRead(fs3);

  if(toe > 10){
    delay(1000);
     weight_measurement_characteristic.indicate32(toe);
     Serial.print("Flexi Force sensor 1: ");
     Serial.print(toe);
     Serial.println("");
  }
  if(ball > 10){
     Serial.print("Flexi Force sensor 2: ");
     Serial.print(ball);
     Serial.println("");
  }
  else{
    
  }
  if(heel > 10){
     Serial.print("Flexi Force sensor 3: ");
     Serial.print(heel);
     Serial.println("");
  }
  else{
    
  }
 
  delay(100);

}
