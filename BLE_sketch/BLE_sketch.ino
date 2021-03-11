BLEService foot_sensor_service = BLEService(UUID16_SVC_FOOT_SENSOR_SERVICE);
BLECharacteristic toe_sensor_characteristic = BLECharacteristic(UUID16_TOE_SENSOR_MEASUREMENT);
BLECharacteristic midfoot_sensor_characteristic = BLECharacteristic(UUID16_MIDFOOT_SENSOR_MEASUREMENT);
BLECharacteristic heel_sensor_characteristic = BLECharacteristic(UUID16_FOOT_SENSOR_MEASUREMENT);



void setup() {
  // put your setup code here, to run once:
  foot_sensor_service.begin();
  // now need to set properties of the characteristics 
  // then need to call begin on the characteristics 

}

void loop() {
  // put your main code here, to run repeatedly:

}
