#include <bluefruit.h>

int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
uint8_t toe = 0;
uint8_t ball = 0;
uint8_t heel = 0;
unsigned long time = 0;

BLEService hrms = BLEService(0x180D);
BLECharacteristic hrmc = BLECharacteristic(0x2A37); //notify 
BLECharacteristic bslc = BLECharacteristic(0x2A38); //read 

//BLEDis bledis;
//BLEBas blebas;


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
  hrms.begin();
  
  hrmc.setProperties(CHR_PROPS_NOTIFY);
  hrmc.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  hrmc.setFixedLen(2);
  //hrmc.setCccdWriteCallback(cccd_callback);
  hrmc.begin();
  uint8_t toe_sensor_data[2] = { 0b00000110, 0x40 };
  hrmc.write(toe_sensor_data, 2);
  

  bslc.setProperties(CHR_PROPS_READ);
  bslc.setPermission(SECMODE_OPEN, SECMODE_NO_ACCESS);
  bslc.setFixedLen(1);
  bslc.begin();
  bslc.write8(6);
}

void startAdv(void){
  Bluefruit.Advertising.addFlags(BLE_GAP_ADV_FLAGS_LE_ONLY_GENERAL_DISC_MODE);
  Bluefruit.Advertising.addTxPower();

  Bluefruit.Advertising.addService(hrms);

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
    if( hrmc.notify(toe_sensor_data, sizeof(toe_sensor_data)) ){
      Serial.print("TOE SENSOR VALUE UPDATED TO: ");
      Serial.println(toe);
    }
    else{
      Serial.println("ERROR");
    }
  }
  delay(1500);

}
