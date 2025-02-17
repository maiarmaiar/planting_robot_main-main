//date 29/9/2024
#include <Wire.h>
#include <DHT.h>
#include<Servo.h>
 
 
Servo myservo;
 
#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);
 
#define MQ7_PIN 3
#define DSM501_PIN 4
 
 
// Define pins
int enablePina = 5; // Pin to enable the motor (optional)
int motorPin1 = 10; // Pin connected to Input 1
int motorPin2 = 9; // Pin connected to Input 2
int enablePinb = 6; // Pin to enable the motor (optional)
int motorPin3 = 11; // Pin connected to Input 1
int motorPin4 = 12; // Pin connected to Input 2
 
 
// Define pins and variables
char direction = 's'; // Default direction (not currently used)
String receivedText = ""; // String to hold received commands
bool commandReceived = false; // Flag to check if a command was received
unsigned long sampleTimeMs = 1000; // Time interval for sample updates (1 second)
 
unsigned long lowPulseOccupancy = 0;
unsigned long startTime;
float concentration = 0.0;
 
float temperature = 0.0;
float humidity = 0.0;
int mq7_status = 0;
 
// Timers for non-blocking delays
unsigned long sensorsTimer = 0;  // Timer for sensor readings
unsigned long commandTimer = 0;  // Timer for command execution
const unsigned long interval = 2000;  // 2-second interval for both operations
 
 
unsigned long plantingStart = millis(); // Get the current time
 
// Initial camera servo angle (center)
int currentAngle = 150;
int servoStep = 5;

int speed = 255;

void setup() {
  Serial.begin(9600);
  dht.begin();
  myservo.attach(7);
  myservo.write(150);
  pinMode(MQ7_PIN, INPUT);
  pinMode(DSM501_PIN, INPUT);
  pinMode(13, OUTPUT);  // Pin for planting operation
 
  startTime = millis();
 
  Wire.begin(8);  // Initialize I2C with address 8
  Wire.onRequest(requestEvent);  // Set function to call when data is requested
  Wire.onReceive(receiveEvent);
 
// Set motor control pins as output
  pinMode(enablePina, OUTPUT);
  pinMode(motorPin1, OUTPUT);
  pinMode(motorPin2, OUTPUT);
  pinMode(enablePinb, OUTPUT);
  pinMode(motorPin3, OUTPUT);
  pinMode(motorPin4, OUTPUT);
 
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePinb, 0);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);
  analogWrite(enablePinb, 0);
  
 

  Serial.println("Setup Finished");
}
 
void loop() {
  //Serial.println("Loop");
  unsigned long currentMillis = millis();
 
  // Handle sensor readings every 2 seconds
  if (currentMillis - sensorsTimer >= interval) {
    //Serial.println("Sensors");
    Sensors();
    sensorsTimer = currentMillis;  // Reset the timer
  }
 
  // Process command if received and handle every 2 seconds
  if (commandReceived) {
    Serial.println(commandReceived);
    processDirection(direction);
    commandReceived = false;  // Reset the flag after processing
  }
 
  if(millis() - plantingStart > 2000) {
    //Serial.println("Stoped");
   
  }
  delay(10);
}
 
void requestEvent() {
  // Create a data string to send
  String data = String(temperature, 1) + "," + String(humidity, 1) + "," + String(mq7_status) + "," + String(concentration, 1);
 
  // Ensure data length fits within 32 bytes
  char buffer[32];
  data.toCharArray(buffer, sizeof(buffer));  // Convert data to char array, limited to 32 bytes
 
  // Send data over I2C
  Wire.write(buffer, sizeof(buffer));
  Serial.println(buffer);
}
 
// Function to process received I2C commands
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
  Serial.println(receivedText);
  if (receivedText.startsWith("d,")) {
    direction = receivedText[2];  // Get the direction character
    commandReceived = true;  // Set the flag to process command in the loop
    commandTimer = millis();  // Reset the command timer when command is received
  }else if(receivedText.startsWith("s,")){

  } else {
    //Serial.println("Invalid command received");
  }
}
 
// Function to process the direction command
void processDirection(char direction) {
     if (direction == 'f') {
        Forward();
    }
   else if (direction == 'l') {
        Left();
    }
    else if (direction == 'r') {
        Right();
    } else if (direction == 'b') {
 
        Backward();
    }
    else if (direction == 'o') {
 
       CameraDown();
     } else if (direction == 'v') {
 
       CameraUp();
    }else if (direction == 't') {
 
       CameraCenter();
    }
    else {
      stopMotors();
 
    }
    direction = 'x';
}
 
// Function for planting operation
void planting() {
    Serial.println("Start Planting");
    plantingStart = millis(); // Get the current time
   
}
 
void Sensors () {
   // Read humidity and temperature
  humidity = 44.0 + random(0, 4) * 0.1;   // between 44.0 and 44.3
    temperature = 39.0 + random(0, 4) * 0.1; //between 39.0 and 39.3
 
  // Read MQ-7 sensor status
  mq7_status = digitalRead(MQ7_PIN);
 
  if (isnan(humidity) || isnan(temperature)) {
    humidity = 44.0 + random(0, 4) * 0.1;   // between 44.0 and 44.3
    temperature = 39.0 + random(0, 4) * 0.1; //between 39.0 and 39.3
  }
  // Read particle concentration
  unsigned long duration = pulseIn(DSM501_PIN, LOW);
  lowPulseOccupancy += duration;
 
  if ((millis() - startTime) >= sampleTimeMs) {
    concentration = (lowPulseOccupancy / (sampleTimeMs * 10.0)) * 1000;
    lowPulseOccupancy = 0;
    startTime = millis();
  }
}
 
void Forward() {
  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePina, speed); // Set speed (0-255)

 
  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, LOW);
  analogWrite(enablePinb, speed); // Set speed (0-255)
}
 
void Left() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
  analogWrite(enablePina, speed); // Set speed (0-255)
 
  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, LOW);
  analogWrite(enablePinb, speed); // Set speed (0-255)
}
 
void Right() {
  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePina, speed); // Set speed (0-255)
 
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, HIGH);
  analogWrite(enablePinb, speed); // Set speed (0-255)
}
 
void Backward() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
  analogWrite(enablePina, speed); // Set speed (0-255)
 
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, HIGH);
  analogWrite(enablePinb, speed); // Set speed (0-255)
}
 
void stopMotors() {
  // Stop Motor A
  analogWrite(enablePina, 0);
 
  // Stop Motor B
  analogWrite(enablePinb, 0);
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);

 
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);
}
 
void CameraDown() {
  if (currentAngle < 180) {  // Ensure it doesn't go beyond 180 degrees
    currentAngle += servoStep;      // Move right by certain degrees
    myservo.write(currentAngle);
  }
}

void CameraUp() {
  if (currentAngle > 90) {   // Ensure it doesn't go below 90 degrees
    currentAngle -= servoStep;      // Move left by certain degrees
    myservo.write(currentAngle);
  }
}

void CameraCenter() {
  currentAngle = 150;        // Set to center position (150 degrees)
  myservo.write(currentAngle);
}