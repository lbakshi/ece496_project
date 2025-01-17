#include <bluefruit.h>
#include <BLEUUID.h>

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

//BLEUuid service_id = BLEUuid("dea53006-ea01-4939-a384-1573aae78dca");
const uint8_t service_id[16] = {0xDE, 0xA5, 0x30, 0x06, 0xEA, 0x01, 0x49, 0x39, 0xA3, 0x84, 0x15, 0x73, 0xAA, 0xE7, 0x8D, 0xCA};
const uint8_t toe_sensor_id[16] = {0xe7, 0x72, 0x5f, 0x91, 0x84, 0xaf, 0x45, 0x27, 0xb0, 0x45, 0x6f, 0x7d, 0x3c, 0xc1, 0xb6, 0x7d};
const uint8_t midfoot_sensor_id[16] = {0xab, 0x77, 0xfa, 0xd9, 0xd2, 0x7b, 0x4c, 0x46, 0x8b, 0x44, 0x77, 0x1b, 0xe5, 0xc0, 0x10, 0x72};
const uint8_t heel_sensor_id[16] = {0x1c, 0x00, 0x50, 0x70, 0x4b, 0xbd, 0x42, 0x8e, 0x86, 0xbd, 0x02, 0x87, 0xd7, 0x77, 0x5a, 0x1e};
uint8_t notify_num = 0x10;

BLEService my_service = BLEService(BLEUuid(service_id));
BLECharacteristic toe_sensor = BLECharacteristic(BLEUuid(toe_sensor_id));
BLECharacteristic midfoot_sensor = BLECharacteristic(BLEUuid(midfoot_sensor_id));
BLECharacteristic heel_sensor = BLECharacteristic(BLEUuid(heel_sensor_id));
BLEDis bledis;
BLEBas blebas;

void setUpWeight(void){
  my_service.begin();

  toe_sensor.setProperties(CHR_PROPS_NOTIFY);
  toe_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  toe_sensor.setFixedLen(2);
  toe_sensor.begin();
  Serial.println("BEFORE NOTIFY");
  //toe_sensor.notify32(toe);

  midfoot_sensor.setProperties(CHR_PROPS_NOTIFY);
  midfoot_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  midfoot_sensor.setFixedLen(2);
  midfoot_sensor.begin();
  //midfoot_sensor.notify32(ball);

  heel_sensor.setProperties(CHR_PROPS_NOTIFY);
  heel_sensor.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  heel_sensor.setFixedLen(2);
  heel_sensor.begin();
  //heel_sensor.notify32(heel);

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
  Serial.println("AT BEGINNING OF SETUP");
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
