#include <bluefruit.h>

// Online generated UUIDs in case we want to implement our own service and characteristics 
//dea53006-ea01-4939-a384-1573aae78dca
//e7725f91-84af-4527-b045-6f7d3cc1b67d
//ab77fad9-d27b-4c46-8b44-771be5c01072
//1c005070-4bbd-428e-86bd-0287d7775a1e

int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
int toe = 0;
int ball = 0;
int heel = 0;
unsigned long time = 0;

BLEService my_service = BLEService('dea53006-ea01-4939-a384-1573aae78dca');
BLECharacteristic toe_sensor = BLECharacteristic('e7725f91-84af-4527-b045-6f7d3cc1b67d');
BLECharacteristic midfoot_sensor = BLECharacteristic('ab77fad9-d27b-4c46-8b44-771be5c01072');
BLECharacteristic heel_sensor = BLECharacteristic('1c005070-4bbd-428e-86bd-0287d7775a1e');
BLEDis bledis;
BLEBas blebas;

void setUpWeight(void){
  my_service.begin();

  toe_sensor.setProperties(CHR_PROPS_NOTIFY);
  toe_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  toe_sensor.setFixedLen(2);
  toe_sensor.begin();
  toe_sensor.notify32(toe);

  midfoot_sensor.setProperties(CHR_PROPS_NOTIFY);
  midfoot_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  midfoot_sensor.setFixedLen(2);
  midfoot_sensor.begin();
  midfoot_sensor.notify32(toe);

  heel_sensor.setProperties(CHR_PROPS_NOTIFY);
  heel_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  heel_sensor.setFixedLen(2);
  heel_sensor.begin();
  heel_sensor.notify32(toe);

}

void startAdv(void){
  // Advertising packet
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE); //not sure what this means
  Bluefruit.Advertising.addTxPower();

  // Include Weight Service UUID
  Bluefruit.Advertising.addService(my_service);

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

void setup() {
  // put your setup code here, to run once:
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

void loop() {
  // put your main code here, to run repeatedly:
  toe = analogRead(fs1);
  ball = analogRead(fs2);
  heel = analogRead(fs3);

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
