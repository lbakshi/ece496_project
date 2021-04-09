#include <bluefruit.h>

float cf = 19.5;
int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
uint8_t toe = 0;
uint8_t ball = 0;
uint8_t heel = 0;
float vout;
unsigned long time = 0;

// PHYSICAL ACTIVITY MONITOR SERVICE - 0x183E
// Physical Activity Monitor Features (M) - Read - 0x2B3B
// General Activity Instantaneous Data (M) - Notify (Toe sensor) - 0x2B3C
// General Activity Summary Data (M) - Indicate - 0x2B3D
// CardioRespiratory Activity Instantaneous Data (O) - Notify (Midfoot sensor) - 0x2B3E
// Sleep Activity Instantaneous Data (O) - Notify (Heel sensor) - 0x2B41
// Physical Activity Monitor Control Point (M) - Write, Indicate - 0x2B43
// Physical Activity Current Session (M) - Indicate, Read - 0x2B44
// Physical Activity Session Descriptor (M) - Indicate - 0x2B45

BLEService pas = BLEService(0x183E);
BLECharacteristic pamf = BLECharacteristic(0x2B3B);
BLECharacteristic toe_sen = BLECharacteristic(0x2B3C);
BLECharacteristic gasd = BLECharacteristic(0x2B3D);
BLECharacteristic midfoot_sen = BLECharacteristic(0x2B3E);
BLECharacteristic heel_sen = BLECharacteristic(0x2B41);
BLECharacteristic pamcp = BLECharacteristic(0x2B43);
BLECharacteristic pacs = BLECharacteristic(0x2B44);
BLECharacteristic pasd = BLECharacteristic(0x2B45);


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("BEGINNING OF SETUP");
  pinMode(fs1, INPUT);
  pinMode(fs2, INPUT);
  pinMode(fs3, INPUT);

  Bluefruit.begin();
  Bluefruit.setName("StrikeSock Bluefruit 2");
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  startAdv();

  setUpProps();

}

void startAdv(void){
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  Bluefruit.Advertising.addService(pas);

  Bluefruit.Advertising.addName();

  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);
}

void setUpProps(void){
  pas.begin();

  pamf.setProperties(CHR_PROPS_READ);
  pamf.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  pamf.setFixedLen(1);
  pamf.begin();
  // not going to read anything 

  toe_sen.setProperties(CHR_PROPS_NOTIFY);
  toe_sen.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  toe_sen.setFixedLen(2);
  toe_sen.begin();
  uint8_t toe_sensor_data[2] = { 0b00000110, 0x40 };
  toe_sen.write(toe_sensor_data, 2);

  gasd.setProperties(CHR_PROPS_INDICATE);
  gasd.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  gasd.setFixedLen(1);
  gasd.begin();
  // not going to indicate anything

  midfoot_sen.setProperties(CHR_PROPS_NOTIFY);
  midfoot_sen.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  midfoot_sen.setFixedLen(2);
  midfoot_sen.begin();
  uint8_t midfoot_sensor_data[2] = { 0b00000110, 0x40 };
  midfoot_sen.write(midfoot_sensor_data, 2);

  heel_sen.setProperties(CHR_PROPS_NOTIFY);
  heel_sen.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  heel_sen.setFixedLen(2);
  heel_sen.begin();
  uint8_t heel_sensor_data[2] = { 0b00000110, 0x40 };
  heel_sen.write(heel_sensor_data, 2);

  pamcp.setProperties(CHR_PROPS_WRITE); // should also be indicate ?
  pamcp.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  pamcp.setFixedLen(1);
  pamcp.begin();
  // not going to write, or indicate anything

  pacs.setProperties(CHR_PROPS_READ); // should also be indicate ?
  pacs.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  pacs.setFixedLen(1);
  pacs.begin();
  // not going to read, or indicate anything 

  pasd.setProperties(CHR_PROPS_INDICATE);
  pasd.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  pasd.setFixedLen(1);
  pasd.begin();
  // not going to indicate anything
  
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
  // put your main code here, to run repeatedly:
  Serial.print("Time: ");
  time = millis();
  Serial.println(time); //prints time since program started
  
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
 
  delay(1000);

}
