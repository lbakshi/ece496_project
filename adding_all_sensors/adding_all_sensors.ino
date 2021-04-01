#include <bluefruit.h>

int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
uint8_t toe = 0;
uint8_t ball = 0;
uint8_t heel = 0;
unsigned long time = 0;

//Fitness Machine Service is 0x1826
//Fitness machine feature (M) is 0x2ACC - read
//Treadmill data (O) is 0x2ACD - notify
//Cross Trainer data (O) is 0x2ACE - notify
//Step Climber data (O) is 0x2ACF - notify
BLEService fms = BLEService(0x1826);
BLECharacteristic fmf = BLECharacteristic(0x2ACC);
BLECharacteristic toe_sen = BLECharacteristic(0x2ACD);
BLECharacteristic midfoot_sen = BLECharacteristic(0x2ACE);
BLECharacteristic heel_sen = BLECharacteristic(0x2ACF);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  Serial.println("BEGINNING OF SETUP");
  pinMode(fs1, INPUT);
  pinMode(fs2, INPUT);
  pinMode(fs3, INPUT);

  Bluefruit.begin();
  Bluefruit.setName("StrikeSock Bluefruit");
  Bluefruit.Periph.setConnectCallback(connect_callback);
  Bluefruit.Periph.setDisconnectCallback(disconnect_callback);

  startAdv();

  setUpProps();

}
void setUpProps(void){
  fms.begin();

  fmf.setProperties(CHR_PROPS_READ);
  fmf.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  fmf.setFixedLen(1);
  fmf.begin();
  fmf.write8(0);

  toe_sen.setProperties(CHR_PROPS_NOTIFY);
  toe_sen.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  toe_sen.setFixedLen(2);
  toe_sen.begin();
  uint8_t toe_sensor_data[2] = { 0b00000110, 0x40 };
  toe_sen.write(toe_sensor_data, 2);

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
  
}

void startAdv(void){
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  Bluefruit.Advertising.addService(fms);

  Bluefruit.Advertising.addName();

  Bluefruit.Advertising.restartOnDisconnect(true);
  Bluefruit.Advertising.setInterval(32, 244);    // in unit of 0.625 ms
  Bluefruit.Advertising.setFastTimeout(30);      // number of seconds in fast mode
  Bluefruit.Advertising.start(0);
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

  Serial.print("Flexi Force sensor 2: ");
  Serial.print(ball);
  Serial.println("");
  Serial.print("Flexi Force sensor 3: ");
  Serial.print(heel);
  Serial.println("");

  if( Bluefruit.connected() ){
    uint8_t toe_sensor_data[2] = { 0b00000110, toe }; 
    Serial.print("Flexi Force sensor 1: ");
    Serial.print(toe);
    Serial.println("");  
    if( toe_sen.notify(toe_sensor_data, sizeof(toe_sensor_data)) ){
      Serial.print("TOE SENSOR VALUE UPDATED TO: ");
      Serial.println(toe);
    }
    else{
      Serial.println("ERROR");
    }
  }

  delay(1500);

}
