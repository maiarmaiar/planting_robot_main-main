#include <Wire.h>
#include <DHT.h>
#include <Servo.h>

Servo myservo;

#define DHTPIN 2
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

#define MQ7_PIN 3
#define DSM501_PIN 4

// Define pins
int enablePina = 5;
int motorPin1 = 10;
int motorPin2 = 9;
int enablePinb = 6;
int motorPin3 = 11;
int motorPin4 = 12;

// Define pins and variables
char direction = 's';
String receivedText = "";
bool commandReceived = false;
unsigned long sampleTimeMs = 1000;

unsigned long lowPulseOccupancy = 0;
unsigned long startTime;
float concentration = 0.0;

float temperature = 0.0;
float humidity = 0.0;
int mq7_status = 0;

unsigned long sensorsTimer = 0;
unsigned long commandTimer = 0;
const unsigned long interval = 2000;

unsigned long plantingStart = millis();

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
  pinMode(13, OUTPUT);

  startTime = millis();
  Wire.begin(8);
  Wire.onRequest(requestEvent);
  Wire.onReceive(receiveEvent);

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
  unsigned long currentMillis = millis();

  if (currentMillis - sensorsTimer >= interval) {
    Sensors();
    sensorsTimer = currentMillis;
  }

  if (commandReceived) {
    processDirection(direction);
    commandReceived = false;
  }

  if (millis() - plantingStart > 2000) {
  }

  delay(10);
}

void requestEvent() {
  String data = String(temperature, 1) + "," + String(humidity, 1) + "," + String(mq7_status) + "," + String(concentration, 1);

  char buffer[32];
  data.toCharArray(buffer, sizeof(buffer));

  if (Wire.write(buffer, sizeof(buffer)) == 0) {
    Serial.println("I2C send error, resetting I2C");
    Wire.end();
    Wire.begin(8);
  } else {
    Serial.println(buffer);
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
  Serial.println(receivedText);
  if (receivedText.startsWith("d,")) {
    direction = receivedText[2];
    commandReceived = true;
    commandTimer = millis();
  }
}

void processDirection(char direction) {
  if (direction == 'f') {
    Forward();
  } else if (direction == 'l') {
    Left();
  } else if (direction == 'r') {
    Right();
  } else if (direction == 'b') {
    Backward();
  } else if (direction == 'o') {
    CameraDown();
  } else if (direction == 'v') {
    CameraUp();
  } else if (direction == 't') {
    CameraCenter();
  } else {
    stopMotors();
  }
  direction = 'x';
}

void planting() {
  Serial.println("Start Planting");
  plantingStart = millis();
}

void Sensors() {
  // Read humidity and temperature
  humidity = dht.readHumidity();
  temperature = dht.readTemperature();

  // Handle sensor read failures
  if (isnan(humidity) || isnan(temperature)) {
    humidity = 0.0;
    temperature = 0.0;
  }

  // Read MQ-7 sensor status
  mq7_status = digitalRead(MQ7_PIN);
  
  if (mq7_status == HIGH) {
    mq7_status = 1;
  } else {
    mq7_status = 0;
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
  analogWrite(enablePina, speed);

  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, LOW);
  analogWrite(enablePinb, speed);
}

void Left() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
  analogWrite(enablePina, speed);

  digitalWrite(motorPin3, HIGH);
  digitalWrite(motorPin4, LOW);
  analogWrite(enablePinb, speed);
}

void Right() {
  digitalWrite(motorPin1, HIGH);
  digitalWrite(motorPin2, LOW);
  analogWrite(enablePina, speed);

  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, HIGH);
  analogWrite(enablePinb, speed);
}

void Backward() {
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, HIGH);
  analogWrite(enablePina, speed);

  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, HIGH);
  analogWrite(enablePinb, speed);
}

void stopMotors() {
  analogWrite(enablePina, 0);
  analogWrite(enablePinb, 0);
  digitalWrite(motorPin1, LOW);
  digitalWrite(motorPin2, LOW);
  digitalWrite(motorPin3, LOW);
  digitalWrite(motorPin4, LOW);
}

void CameraDown() {
  if (currentAngle < 180) {
    currentAngle += servoStep;
    myservo.write(currentAngle);
  }
}

void CameraUp() {
  if (currentAngle > 90) {
    currentAngle -= servoStep;
    myservo.write(currentAngle);
  }
}

void CameraCenter() {
  currentAngle = 150;
  myservo.write(currentAngle);
}
