
//28-9-2024
#include <Wire.h>
#include <PRIZM.h>
 
PRIZM prizm;
int Speed = 100;
char direction = 's';  // Default stop command
String receivedText = "";
bool commandReceived = false; // Flag to process direction in the loop
unsigned long lastCommandTime = 0; // Track last command time
const unsigned long commandTimeout = 2000; // Timeout in milliseconds
 
void processDirection(char direction) {
  if (direction == 'p') {
    planting();
    StartServo();
  }

  }

 
 
void receiveEvent(int howMany) {
  receivedText = "";  
  bool skipFirstChar = true;  
 
  while (Wire.available()) {
    char c = Wire.read();  
   
    if (skipFirstChar) {
      skipFirstChar = false;
      continue;
    }
 
    receivedText += c;  
  }
 
  receivedText.trim();
  if (receivedText.startsWith("d,")) {
    direction = receivedText[2];  // Get the direction character
    commandReceived = true;  // Set the flag to process command in the loop
    lastCommandTime = millis(); // Reset last command time
  } else {
    Serial.println("Invalid command received");
  }
}
 
void setup() {
  Serial.begin(9600);
  prizm.PrizmBegin();
  stopPlanting();
  Wire.begin(9);
  Wire.onReceive(receiveEvent);
  prizm.setMotorTarget(2,360,360);
 
  // for(int i=0;i<5;i++){
  //   int enc = prizm.readEncoderDegrees(2);
  //   Serial.println(enc);
  //   delay(1000);
  // }
  delay(500);
  prizm.resetEncoder(2);
}
 
void loop() {
  //Serial.println("start");
  // Check if a new command was received
  if (commandReceived) {
    processDirection(direction);  // Process the received direction command
    commandReceived = false;  // Reset the flag after processing
    direction = 's';
  }
  // Stop motors if no command has been received within the timeout period
  if (millis() - lastCommandTime > commandTimeout) {
    stopPlanting();
    prizm.setCRServoState(1, 0); // Stop servo
  }
  // direction = 'p';
  // processDirection(direction);
  //  direction = 's';
  //  delay(5000);
 
}
// Movement functions
void planting() {
  Serial.println("Planting");
  prizm.setMotorTarget(2,360,1440);
  delay(1500);
  prizm.resetEncoder(2);
}
void stopPlanting() {
  Serial.println("Stop Planting");
  prizm.setMotorTarget(2,0,0);
}
void  StartServo() {
  prizm.setServoPosition(1,45);  
  delay(200);      
  prizm.setServoPosition(1,90);                                                
}