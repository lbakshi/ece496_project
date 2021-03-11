float cf = 19.5;
int fs1 = A0;
int fs2 = A1;
int fs3 = A2;
int toe = 0;
int ball = 0;
int heel = 0;
float vout;
unsigned long time = 0;


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(fs1, INPUT);
  pinMode(fs2, INPUT);
  pinMode(fs3, INPUT);

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
