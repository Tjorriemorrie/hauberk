import '../../hues.dart';
import '../action/missive.dart';
import '../elements.dart';
import 'builder.dart';

// TODO: Describe other monsters.
void ancients() {}

void birds() {
  family("B")
    ..groups("animal")
    ..sense(see: 8, hear: 6)
    ..defense(10, "{1} flaps out of the way.")
    ..fly()
    ..count(3, 6);
  breed("crow", 4, steelGray, 9, speed: 2, meander: 30)
    ..attack("bite[s]", 5)
    ..drop("treasure", percent: 10)
    ..drop("Black Feather", percent: 25);
  describe(""""What harm can a stupid little crow do?" you think as it and its
      murderous friends dive towards your eyes, claws extended.""");

  breed("raven", 6, slate, 22, meander: 15)
    ..attack("bite[s]", 5)
    ..attack("claw[s]", 4)
    ..drop("treasure", percent: 10)
    ..drop("Black Feather", percent: 20)
    ..flags("protective");
  describe("""It's black eyes gleam with a malevolent intelligence.""");
}

void canids() {}

void greaterDragons() {}

void elementals() {}

void faeFolk() {
  // Sprites, pixies, fairies, elves, etc.

  family("F", speed: 2, meander: 30, flags: "cowardly")
    ..groups("fae")
    ..sense(see: 10, hear: 8)
    ..defense(10, "{1} flits out of the way.")
    ..fly()
    ..preferOpen();
  breed("forest sprite", 2, mint, 6)
    ..attack("scratch[es]", 3)
    ..missive(Missive.insult, rate: 4)
    ..sparkBolt(rate: 7, damage: 4)
    ..drop("treasure", percent: 10)
    ..drop("magic", percent: 60);

  breed("house sprite", 5, cornflower, 10)
    ..attack("poke[s]", 5)
    ..missive(Missive.insult, rate: 4)
    ..stoneBolt(rate: 10, damage: 4)
    ..teleport(rate: 7, range: 4)
    ..drop("treasure", percent: 10)
    ..drop("magic", percent: 80);

  breed("mischievous sprite", 7, salmon, 24)
    ..attack("stab[s]", 6)
    ..missive(Missive.insult, rate: 4)
    ..windBolt(rate: 8, damage: 8)
    ..teleport(range: 5)
    ..drop("treasure", percent: 10)
    ..drop("magic");
}

void golems() {
  // TODO: Animated dolls, poppets, and marionettes.
}

void hybrids() {}

void insubstantials() {}

void krakens() {}

void lichs() {}

void hydras() {}

void demons() {}

void ogres() {}

void giants() {}

void quest() {
  family("Q");
  breed("Nameless Unmaker", 100, violet, 1000, speed: 2)
    ..sense(see: 16, hear: 16)
    ..attack("crushe[s]", 250, Elements.earth)
    ..attack("blast[s]", 200, Elements.lightning)
    ..darkCone(damage: 500)
    ..flags("fearless unique")
    ..openDoors()
    ..drop("treasure", count: 10);
  // TODO: Minions. Moves.
}

void reptiles() {
  family("R")..groups("animal");
  breed("frog", 1, lima, 4, dodge: 30, meander: 30)
    ..sense(see: 6, hear: 4)
    ..swim()
    ..placeIn("aquatic")
    ..attack("hop[s] on", 2);

  family("R", meander: 10, flags: "fearless")
    ..groups("saurian")
    ..sense(see: 10, hear: 5);
  breed("lizard guard", 11, gold, 26)
    ..attack("claw[s]", 8)
    ..attack("bite[s]", 10)
    ..drop("treasure", percent: 30)
    ..drop("armor", percent: 30)
    ..drop("spear", percent: 20);

  breed("lizard protector", 15, lima, 30)
    ..minion("lizard guard", 0, 2)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 14)
    ..drop("treasure", percent: 30)
    ..drop("armor", percent: 30)
    ..drop("spear", percent: 20);

  breed("armored lizard", 17, gunsmoke, 38)
    ..minion("lizard guard", 0, 2)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 15)
    ..drop("treasure", percent: 30)
    ..drop("armor", percent: 50)
    ..drop("spear", percent: 20);

  breed("scaled guardian", 19, steelGray, 50)
    ..minion("lizard protector", 0, 2)
    ..minion("lizard guard", 0, 1)
    ..minion("salamander", 0, 1)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 15)
    ..drop("treasure", percent: 40)
    ..drop("armor", percent: 30)
    ..drop("weapon", percent: 20);

  breed("saurian", 21, carrot, 64)
    ..minion("lizard protector", 0, 2)
    ..minion("armored lizard", 0, 1)
    ..minion("lizard guard", 0, 1)
    ..minion("salamander", 0, 2)
    ..attack("claw[s]", 12)
    ..attack("bite[s]", 17)
    ..drop("treasure", percent: 50)
    ..drop("armor", percent: 30)
    ..drop("weapon", percent: 20);

  family("R", dodge: 30, meander: 20)
    ..groups("animal")
    ..sense(see: 6, hear: 5)
    ..preferOpen()
    ..emanate(3);

  breed("juvenile salamander", 7, salmon, 40)
    ..attack("bite[s]", 14, Elements.fire)
    ..fireCone(rate: 16, damage: 20, range: 4);

  breed("salamander", 13, brickRed, 60)
    ..attack("bite[s]", 18, Elements.fire)
    ..fireCone(rate: 16, damage: 30, range: 5);

  breed("three-headed salamander", 23, maroon, 90)
    ..attack("bite[s]", 24, Elements.fire)
    ..fireCone(rate: 10, damage: 30, range: 5);
}

void snakes() {
  family("S", dodge: 30, meander: 30)
    ..groups("animal")
    ..sense(see: 4, hear: 7);
  breed("water snake", 1, lima, 9)
    ..placeIn("aquatic")
    ..attack("bite[s]", 3);

  breed("brown snake", 3, persimmon, 25)
    ..placeIn("aquatic")
    ..attack("bite[s]", 4);

  breed("cave snake", 8, gunsmoke, 40)
    ..placeIn("passage")
    ..attack("bite[s]", 10);
}

void trolls() {}

void majorUndead() {}

void vampires() {}

void wraiths() {}

void xorns() {}

void serpents() {}
