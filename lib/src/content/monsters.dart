import 'package:malison/malison.dart';

import '../engine.dart';
import '../hues.dart';
import 'drops.dart';
import 'tiles.dart';

/// The last builder that was created. It gets implicitly finished when the
/// next family or breed starts, or at the end of initialization. This way, we
/// don't need an explicit `build()` call at the end of each builder.
_BreedBuilder _builder;

_FamilyBuilder _family = new _FamilyBuilder();

/// While the breeds are being built, we store their minions as string names
/// to avoid problems with circular references between breeds. Once all breeds
/// are defined, we go back and look up the actual breed object for each name.
Map<Breed, List<_NamedMinion>> _minionNames = {};

/// Static class containing all of the [Monster] [Breed]s.
class Monsters {
  // TODO: Now that monsters are spawned using encounters, they no longer need
  // to have a level or be in a resource set.
  static final ResourceSet<Breed> breeds = new ResourceSet();

  static void initialize() {
    breeds.defineTags("monster");

    // Here's approximately the level distributions for the different
    // broad categories on monsters. Monsters are very roughly lumped
    // together so that different depths tend to have a different
    // feel. This doesn't mean that all monsters of a category will
    // fall in that range, just that they tend to. For every family,
    // there will likely be some oddball out of range monsters, like
    // death molds.

    //                   0  10  20  30  40  50  60  70  80  90 100
    // jelly             OOOooo-----
    // bugs              --oooOOOooo-----------
    // animals           ooOOOooooooo------
    // kobolds              --ooOOoo--
    // reptilians               --oooOOOo-
    // humanoids             ----oooooOOOOoooo----
    // plants                  --o--        --oooOoo----
    // orcs                    --ooOOOoo----
    // ogres                        --ooOOOo-
    // undead                            --------oOOOOOoooooo-----
    // trolls                           --ooOOOoooo-------
    // demons                                 -----ooooOOOOooooo--
    // elementals                   --------ooooooooooooo-----
    // golems                                --ooOOOoooo---
    // giants                                     --oooOOOooo-----
    // quylthulgs                                     -----ooooooo
    // mythical beasts                 ----------oooooooOOOOoo----
    // dragons                                  -----oooOOOoo-
    // ancient dragons                               ----ooooOOOOo
    // ancients                                            ---ooOO

    // jelly - unmoving, do interesting things when touched
    // bugs - quick, breed, normal attacks
    // animals - normal normal normal, sometimes groups
    // kobolds - weakest of the "human-like" races that can drop useable stuff
    // reptilians
    // humanoids
    // plants - poison touch, unmoving but very strong
    // orcs
    // ogres
    // undead
    //   zombies - slow, appear in groups, very bad to be touched by
    //   ghosts - quick, bad to be touched by

    // Here's the different letters used for monsters. Letters marked
    // with a * differ from how the letter is used in Angband.

    // a  Arachnid/Scorpion   A  Ancient being
    // b  Giant Bat           B  Bird
    // c  Canine (Dog)        C  Canid (Dog-like humanoid)
    // d  Dragon              D  Ancient Dragon
    // e  Floating Eye        E  Elemental
    // f  Flying Insect       F  Feline (Cat)
    // g  Goblin              G  Golem
    // h  Humanoids           H  Hybrid
    // i  Insect              I  Insubstantial (ghost)
    // j  Jelly/Slime         J  (unused)
    // k  Kobold/Imp/etc      K  Kraken/Land Octopus
    // l  Lizard man          L  Lich
    // m  Mold/Mushroom       M  Multi-Headed Hydra
    // n  Naga                N  Demon
    // o  Orc                 O  Ogre
    // p  Human "person"      P  Giant "person"
    // q  Quadruped           Q  End boss ("quest")
    // r  Rodent/Rabbit       R  Reptile/Amphibian
    // s  Slug                S  Snake
    // t  Troglodyte          T  Troll
    // u  Minor Undead        U  Major Undead
    // v  Vine/Plant          V  Vampire
    // w  Worm or Worm Mass   W  Wight/Wraith
    // x  Skeleton            X  Xorn/Xaren
    // y  Yeek                Y  Yeti
    // z  Zombie/Mummy        Z  Serpent (snake-like dragon)
    // TODO:
    // - Come up with something better than yeeks for "y".
    // - Don't use both "u" and "U" for undead?

    var categories = [
      arachnids, ancients,
      bats, birds,
      canines, canids,
      dragons, greaterDragons,
      eyes, elementals,
      faeFolk, felines,
      goblins, golems,
      humanoids, hybrids,
      insects, insubstantials,
      jellies, // J unused
      kobolds, krakens,
      lizardMen, lichs,
      mushrooms, hydras,
      nagas, demons,
      orcs, ogres,
      people, giants,
      quadrupeds, quest,
      rodents, reptiles,
      slugs, snakes,
      troglodytes, trolls,
      minorUndead, majorUndead,
      vines, vampires,
      worms, wraiths,
      skeletons, xorns,
      /* y and Y? */
      zombies, serpents
    ];

    for (var category in categories) {
      category();
    }

    buildBreed();

    // Now that all the breeds are defined, look up the minions and add them to
    // each breed.
    _minionNames.forEach((breed, minions) {
      breed.minions.addAll(minions.map((named) => new Minion(
          breeds.find(named.breed), named.countMin, named.countMax)));
    });

    // TODO: Build a tag graph for breeds and then use it in places:
    // - Randomly generated themed dungeons that prefer monsters from a certain
    //   tag.
    // - Encounters that pick a couple of monsters from the same tag.
    // - Themed rooms that are filled with a certain tag.
  }
}

void arachnids() {
  // TODO: Should all spiders hide in corridors?
  family("a", flags: "fearless")
    ..preferCorridor()
    ..stain(Tiles.spiderweb);
  breed("brown spider", 1, persimmon, 3, meander: 8)
    ..count(3)
    ..attack("bite[s]", 5);

  breed("gray spider", 2, slate, 6, meander: 6)
    ..count(2, 4)
    ..attack("bite[s]", 5, Element.poison);

  breed("giant spider", 6, ultramarine, 40, meander: 5)
    ..attack("bite[s]", 5, Element.poison)
    ..drop(10, "Stinger");
}

void ancients() {}

void bats() {
  family("b", flags: "fly")..preferWall();
  breed("brown bat", 2, persimmon, 9, speed: 2, meander: 6)
    ..count(2, 4)
    ..attack("bite[s]", 4);

  breed("giant bat", 4, garnet, 24, speed: 2, meander: 4).attack("bite[s]", 6);

  breed("cave bat", 6, gunsmoke, 40, speed: 3, meander: 3)
    ..count(2, 5)
    ..attack("bite[s]", 6);
}

void birds() {
  family("B", flags: "fly")..count(3, 6);
  breed("crow", 4, steelGray, 9, speed: 2, meander: 4)
    ..attack("bite[s]", 5)
    ..drop(25, "Black Feather");

  breed("raven", 6, slate, 22, meander: 1)
    ..attack("bite[s]", 5)
    ..attack("claw[s]", 4)
    ..drop(20, "Black Feather")
    ..flags("protective");
}

void canines() {
  family("c", tracking: 20, meander: 3);
  breed("mangy cur", 2, buttermilk, 11)
    ..count(4)
    ..attack("bite[s]", 4)
    ..howl(range: 6)
    ..drop(20, "Fur Pelt");

  breed("wild dog", 4, gunsmoke, 20)
    ..count(4)
    ..attack("bite[s]", 6)
    ..howl(range: 8)
    ..drop(20, "Fur Pelt");

  breed("mongrel", 7, carrot, 28)
    ..count(2, 5)
    ..attack("bite[s]", 8)
    ..howl(range: 10)
    ..drop(20, "Fur Pelt");
}

void canids() {}

void dragons() {
  // TODO: Tune. Give more attacks. Tune drops.
  family("d")..preferOpen();
  breed("red dragon", 50, brickRed, 400)
    ..attack("bite[s]", 80)
    ..attack("claw[s]", 60)
    ..fireCone(damage: 100)
    ..dropMany(6, "magic")
    ..dropMany(5, "equipment");
}

void greaterDragons() {}

void eyes() {
  family("e", flags: "immobile fly")..preferOpen();
  breed("lazy eye", 1, cornflower, 10)
    ..attack("stare[s] at", 4)
    ..sparkBolt(rate: 6, damage: 10, range: 6);

  breed("mad eye", 5, salmon, 40)
    ..attack("stare[s] at", 6)
    ..windBolt(rate: 6, damage: 20);

  breed("floating eye", 9, buttermilk, 60)
    ..attack("stare[s] at", 8)
    ..sparkBolt(rate: 5, damage: 16)
    ..teleport(rate: 8, range: 7);

  breed("baleful eye", 20, carrot, 80)
    ..attack("gaze[s] into", 12)
    ..fireBolt(rate: 4, damage: 20)
    ..waterBolt(rate: 4, damage: 20)
    ..teleport(rate: 8, range: 9);

  breed("malevolent eye", 30, brickRed, 120)
    ..attack("gaze[s] into", 20)
    ..lightBolt(rate: 4, damage: 20)
    ..darkBolt(rate: 4, damage: 20)
    ..fireCone(rate: 7, damage: 30)
    ..teleport(rate: 8, range: 9);

  breed("murderous eye", 40, maroon, 180)
    ..attack("gaze[s] into", 30)
    ..acidBolt(rate: 7, damage: 50)
    ..stoneBolt(rate: 7, damage: 50)
    ..iceCone(rate: 7, damage: 40)
    ..teleport(rate: 8, range: 9);

  breed("watcher", 60, gunsmoke, 300)
    ..attack("see[s]", 50)
    ..lightBolt(rate: 7, damage: 40)
    ..lightCone(rate: 7, damage: 60)
    ..darkBolt(rate: 7, damage: 50)
    ..darkCone(rate: 7, damage: 70);

  // beholder, undead beholder, rotting beholder
}

void elementals() {}

void faeFolk() {
  // Sprites, pixies, fairies, elves, etc.

  // TODO: Make them fly.
  family("f", speed: 2, meander: 4, flags: "cowardly fly")..preferOpen();
  breed("forest sprite", 1, mint, 6)
    ..count(2)
    ..attack("scratch[es]", 3)
    ..sparkBolt(rate: 7, damage: 4)
    ..teleport(rate: 7, range: 5)
    ..drop(60, "magic");

  breed("house sprite", 3, cornflower, 15)
    ..count(2)
    ..attack("poke[s]", 5)
    ..stoneBolt(rate: 10, damage: 4)
    ..teleport(rate: 7, range: 5)
    ..drop(80, "magic");

  breed("mischievous sprite", 7, salmon, 24)
    ..count(2)
    ..attack("stab[s]", 6)
    ..windBolt(rate: 8, damage: 8)
    ..teleport(range: 7)
    ..insult(rate: 6)
    ..drop(100, "magic");
}

void felines() {
  family("F");
  breed("stray cat", 1, gold, 9, speed: 1, meander: 3)
    ..attack("bite[s]", 5)
    ..attack("scratch[es]", 4);
}

void goblins() {
  family("g", meander: 1, flags: "open-doors");
  breed("goblin peon", 4, persimmon, 20, meander: 2)
    ..count(4)
    ..attack("stab[s]", 5)
    ..drop(10, "spear")
    ..drop(5, "healing");

  breed("goblin archer", 6, peaGreen, 22)
    ..count(2)
    ..minion("goblin peon", 0, 2)
    ..attack("stab[s]", 3)
    ..arrow(rate: 3, damage: 4)
    ..drop(20, "bow")
    ..drop(10, "dagger")
    ..drop(5, "healing");

  breed("goblin fighter", 6, persimmon, 30)
    ..count(2)
    ..minion("goblin archer", 0, 1)
    ..minion("goblin peon", 0, 3)
    ..attack("stab[s]", 7)
    ..drop(15, "spear")
    ..drop(10, "armor")
    ..drop(5, "resistance")
    ..drop(5, "healing");

  breed("goblin warrior", 8, gunsmoke, 42)
    ..count(2)
    ..minion("goblin fighter", 0, 1)
    ..minion("goblin archer", 0, 1)
    ..minion("goblin peon", 0, 3)
    ..attack("stab[s]", 10)
    ..drop(20, "axe")
    ..drop(20, "armor")
    ..drop(5, "resistance")
    ..drop(5, "healing")
    ..flags("protective");

  breed("goblin mage", 9, ultramarine, 30)
    ..minion("goblin fighter", 0, 1)
    ..minion("goblin archer", 0, 1)
    ..minion("goblin peon", 0, 2)
    ..attack("whip[s]", 7)
    ..fireBolt(rate: 12, damage: 6)
    ..sparkBolt(rate: 12, damage: 8)
    ..drop(10, "equipment")
    ..drop(10, "whip")
    ..drop(20, "magic");

  breed("goblin ranger", 12, sherwood, 36)
    ..minion("goblin mage", 0, 1)
    ..minion("goblin fighter", 0, 1)
    ..minion("goblin archer", 0, 1)
    ..minion("goblin peon", 0, 2)
    ..attack("stab[s]", 10)
    ..arrow(rate: 3, damage: 8)
    ..drop(30, "bow")
    ..drop(20, "armor")
    ..drop(20, "magic");

  // TODO: Always drop something good.
  breed("Erlkonig, the Goblin Prince", 14, steelGray, 80)
    ..minion("goblin mage", 1, 2)
    ..minion("goblin fighter", 1, 3)
    ..minion("goblin archer", 1, 3)
    ..minion("goblin peon", 2, 4)
    ..attack("hit[s]", 10)
    ..attack("slash[es]", 14)
    ..darkBolt(rate: 20, damage: 10)
    ..drop(60, "equipment")
    ..drop(60, "equipment")
    ..drop(40, "magic")
    ..flags("protective");
}

void golems() {}

void humanoids() {}

void hybrids() {}

void insects() {
  family("i", tracking: 3, meander: 8, flags: "fearless");
  // TODO: Spawn as eggs which can hatch into cockroaches?
  breed("giant cockroach[es]", 1, garnet, 4)
    ..count(3, 5)
    ..preferCorner()
    ..attack("crawl[s] on", 2)
    ..spawn(rate: 6);

  breed("giant centipede", 3, brickRed, 16, speed: 3, meander: -4)
    ..preferCorridor()
    ..attack("crawl[s] on", 4)
    ..attack("bite[s]", 8);
}

void insubstantials() {}

void jellies() {
  family("j", speed: -1, flags: "fearless")
    ..preferWall()
    ..count(4);
  breed("green jelly", 1, lima, 5)
    ..stain(Tiles.greenJellyStain)
    ..attack("crawl[s] on", 3);
  // TODO: More elements.

  family("j", flags: "fearless immobile")
    ..preferCorner()
    ..count(4);
  breed("green slime", 2, peaGreen, 7)
    ..stain(Tiles.greenJellyStain)
    ..attack("crawl[s] on", 4)
    ..spawn(rate: 4);

  breed("frosty slime", 4, ash, 14)
    ..stain(Tiles.whiteJellyStain)
    ..attack("crawl[s] on", 5, Element.cold)
    ..spawn(rate: 4);

  breed("mud slime", 6, persimmon, 20)
    ..stain(Tiles.brownJellyStain)
    ..attack("crawl[s] on", 8, Element.earth)
    ..spawn(rate: 4);

  breed("smoking slime", 15, brickRed, 30)
    ..stain(Tiles.redJellyStain)
    ..attack("crawl[s] on", 10, Element.fire)
    ..spawn(rate: 4);

  breed("sparkling slime", 20, violet, 40)
    ..stain(Tiles.violetJellyStain)
    ..attack("crawl[s] on", 12, Element.lightning)
    ..spawn(rate: 4);

  // TODO: Erode nearby walls?
  breed("caustic slime", 25, mint, 50)
    ..stain(Tiles.greenJellyStain)
    ..attack("crawl[s] on", 13, Element.acid)
    ..spawn(rate: 4);

  breed("virulent slime", 35, sherwood, 60)
    ..stain(Tiles.greenJellyStain)
    ..attack("crawl[s] on", 14, Element.poison)
    ..spawn(rate: 4);

  // TODO: Fly?
  breed("ectoplasm", 45, steelGray, 40)
    ..stain(Tiles.grayJellyStain)
    ..attack("crawl[s] on", 15, Element.spirit)
    ..spawn(rate: 4);
}

void kobolds() {
  family("k", speed: 2, meander: 4, flags: "cowardly");
  breed("scurrilous imp", 4, salmon, 18, meander: 4)
    ..count(2)
    ..attack("club[s]", 4)
    ..insult()
    ..haste()
    ..drop(20, "club")
    ..drop(20, "speed")
    ..flags("cowardly");

  breed("vexing imp", 4, violet, 19, speed: 1, meander: 2)
    ..count(2)
    ..minion("scurrilous imp", 0, 1)
    ..attack("scratch[es]", 4)
    ..insult()
    ..sparkBolt(rate: 5, damage: 6)
    ..drop(30, "teleportation")
    ..flags("cowardly");

  family("k", speed: 1, meander: 3);
  breed("kobold", 5, brickRed, 16, meander: 2)
    ..count(3)
    ..minion("wild dog", 0, 3)
    ..attack("poke[s]", 4)
    ..teleport(rate: 6, range: 6)
    ..drop(30, "magic");

  breed("kobold shaman", 10, ultramarine, 16, meander: 2)
    ..count(2)
    ..minion("wild dog", 0, 3)
    ..attack("hit[s]", 4)
    ..teleport(rate: 5, range: 6)
    ..waterBolt(rate: 5, damage: 6)
    ..drop(40, "magic");

  breed("kobold trickster", 13, gold, 20, meander: 2)
    ..attack("hit[s]", 5)
    ..sparkBolt(rate: 5, damage: 8)
    ..teleport(rate: 5, range: 6)
    ..haste(rate: 7)
    ..drop(40, "magic");

  breed("kobold priest", 15, cerulean, 25, meander: 2)
    ..count(2)
    ..minion("kobold", 1, 3)
    ..attack("club[s]", 6)
    ..heal(rate: 15, amount: 10)
    ..fireBolt(rate: 10, damage: 8)
    ..teleport(rate: 5, range: 6)
    ..haste(rate: 7)
    ..drop(30, "club")
    ..drop(40, "magic");

  breed("imp incanter", 11, lilac, 18, speed: 1, meander: 4)
    ..count(2)
    ..minion("kobold", 1, 3)
    ..minion("wild dog", 0, 3)
    ..attack("scratch[es]", 4)
    ..insult()
    ..fireBolt(rate: 5, damage: 10)
    ..drop(50, "magic")
    ..flags("cowardly");

  breed("imp warlock", 14, indigo, 40, speed: 1, meander: 3)
    ..minion("imp incanter", 1, 3)
    ..minion("kobold", 1, 3)
    ..minion("wild dog", 0, 3)
    ..attack("stab[s]", 5)
    ..iceBolt(rate: 8, damage: 12)
    ..fireBolt(rate: 8, damage: 12)
    ..drop(30, "staff")
    ..drop(50, "magic")
    ..flags("cowardly");

  // TODO: Always drop something good.
  breed("Feng", 20, carrot, 60, speed: 1, meander: 3)
    ..minion("imp warlock", 1, 2)
    ..minion("imp incanter", 1, 2)
    ..minion("kobold priest", 1, 2)
    ..minion("kobold", 1, 3)
    ..minion("wild dog", 0, 3)
    ..attack("stab[s]", 5)
    ..teleport(rate: 5, range: 6)
    ..teleport(rate: 50, range: 30)
    ..insult()
    ..lightningCone(rate: 8, damage: 12)
    ..drop(50, "spear", 5)
    ..drop(40, "armor", 5)
    ..drop(40, "armor", 5)
    ..drop(50, "magic", 5)
    ..drop(50, "magic", 5)
    ..drop(50, "magic", 5)
    ..flags("cowardly");

  // homonculous
}

void krakens() {}

void lizardMen() {
  // troglodyte
  // reptilian
}

void lichs() {}
void mushrooms() {}
void hydras() {}
void nagas() {}
void demons() {}
void orcs() {}
void ogres() {}

void people() {
  family("p", tracking: 14, flags: "open-doors");
  breed("hapless adventurer", 1, buttermilk, 12, meander: 3)
    ..attack("hit[s]", 3)
    ..drop(50, "weapon")
    ..drop(60, "armor")
    ..drop(40, "magic")
    ..flags("cowardly");

  breed("simpering knave", 2, carrot, 15, meander: 3)
    ..attack("hit[s]", 2)
    ..attack("stab[s]", 4)
    ..drop(40, "whip")
    ..drop(40, "armor")
    ..drop(30, "magic")
    ..flags("cowardly");

  breed("decrepit mage", 3, violet, 16, meander: 2)
    ..attack("hit[s]", 2)
    ..sparkBolt(rate: 10, damage: 8)
    ..drop(60, "magic")
    ..drop(30, "dagger")
    ..drop(20, "staff")
    ..drop(20, "robe")
    ..drop(20, "boots");

  breed("unlucky ranger", 5, peaGreen, 20, meander: 2)
    ..attack("slash[es]", 2)
    ..arrow(rate: 4, damage: 2)
    ..drop(30, "potion")
    ..drop(40, "bow")
    ..drop(10, "sword")
    ..drop(10, "body");

  breed("drunken priest", 5, cerulean, 18, meander: 4)
    ..attack("hit[s]", 8)
    ..heal(rate: 15, amount: 8)
    ..drop(30, "scroll")
    ..drop(20, "club")
    ..drop(40, "robe")
    ..flags("fearless");
}

void giants() {}

void quadrupeds() {}

void quest() {}

void rodents() {
  family("r", meander: 4)..preferWall();
  breed("[mouse|mice]", 1, sandal, 6, speed: 1)
    ..count(2, 5)
    ..attack("bite[s]", 3)
    ..attack("scratch[es]", 2);

  breed("sewer rat", 2, steelGray, 7, speed: 1, meander: -1)
    ..count(2, 5)
    ..attack("bite[s]", 4)
    ..attack("scratch[es]", 3);

  breed("sickly rat", 3, peaGreen, 4, speed: 1)
    ..attack("bite[s]", 3, Element.poison)
    ..attack("scratch[es]", 3);

  breed("plague rat", 6, lima, 10, speed: 1)
    ..count(2, 4)
    ..attack("bite[s]", 4, Element.poison)
    ..attack("scratch[es]", 3);
}

void reptiles() {
  family("R");
  breed("frog", 1, lima, 4, speed: 1, meander: 4)
    ..preferGrass()
    ..attack("hop[s] on", 2);

  // TODO: Drop scales?
  family("R", meander: 1, flags: "fearless");
  breed("lizard guard", 11, gold, 26)
    ..attack("claw[s]", 8)
    ..attack("bite[s]", 10);

  breed("lizard protector", 15, lima, 30)
    ..minion("lizard guard", 0, 2)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 14);

  breed("armored lizard", 17, gunsmoke, 38)
    ..minion("lizard guard", 0, 2)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 15);

  breed("scaled guardian", 19, steelGray, 50)
    ..minion("lizard protector", 0, 2)
    ..minion("lizard guard", 0, 1)
    ..minion("salamander", 0, 1)
    ..attack("claw[s]", 10)
    ..attack("bite[s]", 15);

  breed("saurian", 21, carrot, 64)
    ..minion("lizard protector", 0, 2)
    ..minion("armored lizard", 0, 1)
    ..minion("lizard guard", 0, 1)
    ..minion("salamander", 0, 2)
    ..attack("claw[s]", 12)
    ..attack("bite[s]", 17);

  family("R", meander: 3)..preferOpen();
  breed("juvenile salamander", 7, salmon, 24)
    ..attack("bite[s]", 12, Element.fire)
    ..fireCone(rate: 16, damage: 18, range: 6);

  breed("salamander", 13, brickRed, 40)
    ..attack("bite[s]", 16, Element.fire)
    ..fireCone(rate: 16, damage: 24, range: 8);
}

void slugs() {
  family("s", tracking: 2, flags: "fearless", meander: 1, speed: -3);
  breed("giant slug", 1, mustard, 20)..attack("crawl[s] on", 7);

  breed("suppurating slug", 6, lima, 30)
    ..attack("crawl[s] on", 7, Element.poison);
}

void snakes() {
  family("S", speed: 1, meander: 4);
  breed("garter snake", 1, lima, 7)
    ..preferGrass()
    ..attack("bite[s]", 3);

  breed("brown snake", 3, persimmon, 14)
    ..preferGrass()
    ..attack("bite[s]", 4);

  breed("cave snake", 7, gunsmoke, 35)
    ..preferCorridor()
    ..attack("bite[s]", 10);
}

void troglodytes() {}
void trolls() {}
void minorUndead() {}
void majorUndead() {}
void vines() {}
void vampires() {}

void worms() {
  family("w", meander: 4, flags: "fearless");
  breed("giant earthworm", 2, salmon, 20, speed: -2)
    ..preferCorridor()
    ..attack("crawl[s] on", 4);

  breed("blood worm", 2, brickRed, 4, rarity: 2)
    ..count(3, 8)
    ..attack("crawl[s] on", 5);

  breed("giant cave worm", 7, sandal, 36, speed: -2)
    ..preferCorridor()
    ..attack("crawl[s] on", 8, Element.acid);

  breed("fire worm", 10, carrot, 6)
    ..count(2, 6)
    ..preferWall()
    ..attack("crawl[s] on", 5, Element.fire);
}

void wraiths() {}

void skeletons() {}

void xorns() {}

void zombies() {}
void serpents() {}

_FamilyBuilder family(String character,
    {int meander, int speed, int tracking, String flags}) {
  buildBreed();

  _family = new _FamilyBuilder();
  _family._character = character;
  _family._meander = meander;
  _family._speed = speed;
  _family._tracking = tracking;
  _family._flags = flags;

  return _family;
}

void buildBreed() {
  if (_builder == null) return;

  var breed = _builder.build();
  Monsters.breeds
    ..add(breed.name, breed, breed.depth, _builder._rarity, "monster");
  _builder = null;
}

// TODO: Move more named params into builder methods?
_BreedBuilder breed(String name, int depth, appearance, int health,
    {int rarity: 1, int speed: 0, int meander: 0}) {
  buildBreed();

  Glyph glyph;
  if (appearance is Color) {
    glyph = new Glyph(_family._character, appearance, midnight);
  } else {
    glyph = appearance(_family._character);
  }

  _builder = new _BreedBuilder(name, depth, rarity, glyph, health);
  _builder._speed = speed;
  _builder._meander;
  return _builder;
}

class _BaseBuilder {
  int _tracking;

  SpawnLocation _location;

  /// The default speed for breeds in the current family. If the breed
  /// specifies a speed, it offsets the family's speed.
  int _speed;

  /// The default meander for breeds in the current family. If the breed
  /// specifies a meander, it offset's the family's meander.
  int _meander;

  String _flags;

  int _countMin;
  int _countMax;

  TileType _stain;

  void preferWall() {
    _location = SpawnLocation.wall;
  }

  void preferCorner() {
    _location = SpawnLocation.corner;
  }

  void preferCorridor() {
    _location = SpawnLocation.corridor;
  }

  void preferGrass() {
    _location = SpawnLocation.grass;
  }

  void preferOpen() {
    _location = SpawnLocation.open;
  }

  /// How many monsters of this kind are spawned.
  void count(int minOrMax, [int max]) {
    if (max == null) {
      _countMin = 1;
      _countMax = minOrMax;
    } else {
      _countMin = minOrMax;
      _countMax = max;
    }
  }

  void stain(TileType type) {
    _stain = type;
  }
}

class _FamilyBuilder extends _BaseBuilder {
  /// Character for the current monster.
  String _character;
}

class _BreedBuilder extends _BaseBuilder {
  final String _name;
  final int _depth;
  final int _rarity;
  final Object _appearance;
  final int _health;
  final List<Attack> _attacks = [];
  final List<Move> _moves = [];
  final List<Drop> _drops = [];
  final List<_NamedMinion> _minions = [];

  _BreedBuilder(
      this._name, this._depth, this._rarity, this._appearance, this._health) {}

  void minion(String name, [int minOrMax, int max]) {
    if (minOrMax == null) {
      minOrMax = 1;
      max = 1;
    } else if (max == null) {
      max = minOrMax;
      minOrMax = 1;
    }

    _minions.add(new _NamedMinion(name, minOrMax, max));
  }

  void attack(String verb, int damage, [Element element, Noun noun]) {
    _attacks.add(new Attack(noun, verb, damage, 0, element));
  }

  void drop(int chance, String name, [int depthOffset = 0]) {
    _drops.add(percentDrop(chance, name, _depth + depthOffset));
  }

  void dropMany(int count, String name, [int depthOffset = 0]) {
    _drops.add(repeatDrop(count, name, _depth + depthOffset));
  }

  void flags(String flags) {
    // TODO: Allow negated flags.
    _flags = flags;
  }

  void heal({num rate: 5, int amount}) => _addMove(new HealMove(rate, amount));

  void arrow({num rate: 5, int damage}) =>
      _bolt("the arrow", "hits", Element.none, damage, rate, 8);

  void windBolt({num rate: 5, int damage}) =>
      _bolt("the wind", "blows", Element.air, damage, rate, 8);

  void stoneBolt({num rate: 5, int damage}) =>
      _bolt("the stone", "hits", Element.earth, damage, rate, 8);

  void waterBolt({num rate: 5, int damage}) =>
      _bolt("the jet", "splashes", Element.water, damage, rate, 8);

  void sparkBolt({num rate: 5, int damage, int range: 8}) =>
      _bolt("the spark", "zaps", Element.lightning, damage, rate, range);

  void iceBolt({num rate: 5, int damage, int range: 8}) =>
      _bolt("the ice", "freezes", Element.cold, damage, rate, range);

  void fireBolt({num rate: 5, int damage}) =>
      _bolt("the flame", "burns", Element.fire, damage, rate, 8);

  void lightningBolt({num rate: 5, int damage}) =>
      _bolt("the lightning", "shocks", Element.lightning, damage, rate, 10);

  void acidBolt({num rate: 5, int damage, int range: 8}) =>
      _bolt("the acid", "burns", Element.acid, damage, rate, range);

  void darkBolt({num rate: 5, int damage}) =>
      _bolt("the darkness", "crushes", Element.dark, damage, rate, 10);

  void lightBolt({num rate: 5, int damage}) =>
      _bolt("the light", "sears", Element.light, damage, rate, 10);

  void poisonBolt({num rate: 5, int damage}) =>
      _bolt("the poison", "engulfs", Element.poison, damage, rate, 8);

  void windCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the wind", "buffets", Element.air, rate, damage, range);

  void fireCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the flame", "burns", Element.fire, rate, damage, range);

  void iceCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the ice", "freezes", Element.cold, rate, damage, range);

  void lightningCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the lightning", "shocks", Element.lightning, rate, damage, range);

  void lightCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the light", "sears", Element.light, rate, damage, range);

  void darkCone({num rate: 5, int damage, int range: 10}) =>
      _cone("the darkness", "crushes", Element.dark, rate, damage, range);

  void insult({num rate: 5}) => _addMove(new InsultMove(rate));

  void howl({num rate: 10, int range: 10}) =>
      _addMove(new HowlMove(rate, range));

  void haste({num rate: 5, int duration: 10, int speed: 1}) =>
      _addMove(new HasteMove(rate, duration, speed));

  void teleport({num rate: 5, int range: 10}) =>
      _addMove(new TeleportMove(rate, range));

  void spawn({num rate: 10}) => _addMove(new SpawnMove(rate));

  void _bolt(String noun, String verb, Element element, num rate, int damage,
      int range) {
    _addMove(new BoltMove(
        rate, new Attack(new Noun(noun), verb, damage, range, element)));
  }

  void _cone(String noun, String verb, Element element, num rate, int damage,
      int range) {
    _addMove(new ConeMove(
        rate, new Attack(new Noun(noun), verb, damage, range, element)));
  }

  void _addMove(Move move) {
    _moves.add(move);
  }

  Breed build() {
    var flags = new Set<String>();
    if (_family._flags != null) flags.addAll(_family._flags.split(" "));
    if (_flags != null) flags.addAll(_flags.split(" "));

    var breed = new Breed(
        _name,
        Pronoun.it,
        _appearance,
        _attacks,
        _moves,
        dropAllOf(_drops),
        _location ?? _family._location ?? SpawnLocation.anywhere,
        depth: _depth,
        maxHealth: _health,
        tracking: (_tracking ?? 0) + (_family._tracking ?? 10),
        meander: (_meander ?? 0) + (_family._meander ?? 0),
        speed: (_speed ?? 0) + (_family._speed ?? 0),
        countMin: _countMin ?? _family._countMin ?? 1,
        countMax: _countMax ?? _family._countMax ?? 1,
        stain: _stain ?? _family._stain,
        flags: flags);

    _minionNames[breed] = _minions;

    return breed;
  }
}

class _NamedMinion {
  final String breed;
  final int countMin;
  final int countMax;

  _NamedMinion(this.breed, this.countMin, this.countMax);
}
