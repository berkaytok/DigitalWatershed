import oscP5.*;
import netP5.*;


ArrayList<Particle> particles;
ArrayList<Trail> trails;
float noiseScale = 0.01;
int maxTrails = 300; //
int maxParticles = 150;
float generationRate = 0.05; 
float maxGlowSize = 12;  
float glowDuration = 60; 

OscP5 oscP5;
NetAddress supercollider;

void setup() {
  fullScreen();
  background(0);
  
  oscP5 = new OscP5(this, 12000);
  supercollider = new NetAddress("127.0.0.1", 57120);
  
  particles = new ArrayList<Particle>();
  trails = new ArrayList<Trail>();
  
  for (int i = 0; i < 100; i++) {
    particles.add(new Particle());
  }
}

void draw() {
 fill(0, 5);
 rect(0, 0, width, height);
 
 if (random(1) < generationRate && particles.size() < maxParticles) {
   Particle p = new Particle();
   particles.add(p);
   OscMessage msg = new OscMessage("/shimmer");
   msg.add(map(p.position.x, 0, width, 0, 1));
   msg.add(map(p.position.y, 0, height, 0, 1));
   oscP5.send(msg, supercollider);
 }
 
 for (int i = trails.size() - 1; i >= 0; i--) {
   Trail trail = trails.get(i);
   trail.update();
   trail.display();
   if (trail.isDead()) {
     trails.remove(i);
   }
 }
 
 for (int i = particles.size() - 1; i >= 0; i--) {
   Particle p = particles.get(i);
   p.update();
   p.display();
   
   if (random(1) < 0.1) {
     trails.add(new Trail(p.position.x, p.position.y));
   }
   
   if (p.isDead()) {
     particles.remove(i);
   }
 }
 
 while (trails.size() > maxTrails) {
   trails.remove(0);
 }
}

class Particle {
 PVector position;
 PVector velocity;
 float size;
 float alpha;
 float lifespan;
 float baseSpeed;
 float birthTime;
 float originalSize;
 
 Particle() {
   position = new PVector(random(width), random(height));
   velocity = new PVector(0, 0);
   birthTime = frameCount;
   originalSize = random(2, 4);
   size = originalSize;
   alpha = random(50, 150);
   lifespan = random(200, 600);
   baseSpeed = random(0.2, 0.4);
 }
 
 void update() {
   float angle = noise(position.x * noiseScale, position.y * noiseScale) * TWO_PI * 2;
   velocity.x = cos(angle) * baseSpeed;
   velocity.y = sin(angle) * baseSpeed;
   
   position.add(velocity);
   
   if (position.x < 0) position.x = width;
   if (position.x > width) position.x = 0;
   if (position.y < 0) position.y = height;
   if (position.y > height) position.y = 0;
   
   alpha = map(noise(frameCount * 0.005 + position.x), 0, 1, 50, 150);
   lifespan -= 0.2;
 }
 
 void display() {
   noStroke();
   float fadeAlpha = map(lifespan, 0, 200, 0, alpha);
   
   float age = frameCount - birthTime;
   if (age < glowDuration) {
     float glowFactor = map(age, 0, glowDuration, maxGlowSize, originalSize);
     size = glowFactor;
     fadeAlpha *= map(age, 0, glowDuration, 1.5, 1.0);
   }
   
   fill(255, fadeAlpha);
   ellipse(position.x, position.y, size, size);
 }
 
 boolean isDead() {
   return lifespan < 0;
 }
}

class Trail {
  PVector position;
  float size;
  float alpha;
  float lifespan;
  
  Trail(float x, float y) {
    position = new PVector(x, y);
    size = random(1, 3);
    alpha = random(50, 150);
    lifespan = 255;
  }
  
  void update() {
    lifespan -= 0.5;
  }
  
  void display() {
    noStroke();
    float fadeAlpha = map(lifespan, 0, 255, 0, alpha);
    fill(255, fadeAlpha);
    ellipse(position.x, position.y, size, size);
  }
  
  boolean isDead() {
    return lifespan < 0;
  }
}
