class Question {
  final String question;
  final List<String> options;
  final int answerIndex;

  Question({
    required this.question,
    required this.options,
    required this.answerIndex,
  });
}

List<Question> allquestions = [
  Question(
    question: "Which city is featured in GTA 6?",
    options: [
      "Las Venturas",
      "Liberty City",
      "Vice City",
      "Los Santos",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who developed GTA 6?",
    options: [
      "Rockstar Games",
      "EA",
      "Valve",
      "Ubisoft",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the fictional state featured in GTA 6?",
    options: [
      "Alderney",
      "Liberty",
      "Leonida",
      "San Andreas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who is the female protagonist of GTA 6?",
    options: [
      "Amanda",
      "Lucia",
      "Tracey",
      "Catalina",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which company develops GTA 6?",
    options: [
      "Electronic Arts",
      "Ubisoft",
      "Rockstar Games",
      "Valve",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which city returns in GTA 6?",
    options: [
      "Carcer City",
      "Vice City",
      "Los Santos",
      "Liberty City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What genre is GTA 6?",
    options: [
      "Strategy",
      "Sports",
      "Open World Action-Adventure",
      "Racing",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which publisher releases GTA 6?",
    options: [
      "Sony",
      "Microsoft",
      "Take-Two Interactive",
      "Nintendo",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of the male protagonist shown in the trailers?",
    options: [
      "Trevor",
      "Niko",
      "Jason",
      "Franklin",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which platform is GTA 6 launching on first?",
    options: [
      "PlayStation 5 and Xbox Series X|S",
      "Mobile",
      "Nintendo Switch",
      "PC",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which state is Leonida inspired by?",
    options: [
      "Nevada",
      "California",
      "Florida",
      "Texas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which fictional city is inspired by Miami?",
    options: [
      "Liberty City",
      "Vice City",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which game series does GTA 6 belong to?",
    options: [
      "Grand Theft Auto",
      "Saints Row",
      "Watch Dogs",
      "Red Dead Redemption",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the main setting of GTA 6 called?",
    options: [
      "San Fierro",
      "North Yankton",
      "Liberty State",
      "Leonida",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What does GTA stand for?",
    options: [
      "Grand Tour Action",
      "Game Theft Arena",
      "Grand Theft Auto",
      "Great Truck Adventure",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which company develops GTA games?",
    options: [
      "Ubisoft",
      "Rockstar Games",
      "Valve",
      "EA",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of the fictional state in GTA 6?",
    options: [
      "San Andreas",
      "Yankton",
      "Liberty",
      "Leonida",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which company publishes GTA 6?",
    options: [
      "Sony",
      "Nintendo",
      "Take-Two Interactive",
      "Microsoft",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced Trevor?",
    options: [
      "GTA IV",
      "GTA Vice City",
      "GTA San Andreas",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is one of the protagonists in GTA V?",
    options: [
      "Niko Bellic",
      "Carl Johnson",
      "Franklin Clinton",
      "Tommy Vercetti",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the nickname of GTA San Andreas' main character?",
    options: [
      "RJ",
      "CJ",
      "BJ",
      "TJ",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is the main character of GTA Vice City?",
    options: [
      "Franklin",
      "Trevor",
      "Michael",
      "Tommy Vercetti",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which city is featured in GTA V?",
    options: [
      "Liberty City",
      "San Fierro",
      "Los Santos",
      "Vice City",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What color is the GTA V logo's number five?",
    options: [
      "Yellow",
      "Blue",
      "Red",
      "Green",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which console generation first got GTA V?",
    options: [
      "PS5/Xbox Series X",
      "PS3/Xbox 360",
      "PS2/Xbox",
      "Nintendo Switch",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of Michael's son in GTA V?",
    options: [
      "Ryder",
      "Lamar",
      "Roman",
      "Jimmy",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of Franklin's dog?",
    options: [
      "Max",
      "Chop",
      "Buddy",
      "Rex",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game features Niko Bellic?",
    options: [
      "Vice City",
      "GTA V",
      "GTA IV",
      "GTA III",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which country is Niko Bellic from?",
    options: [
      "Serbia",
      "Mexico",
      "USA",
      "France",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of the radio station hosted by Lazlow?",
    options: [
      "Radio Los Santos",
      "V-Rock",
      "Chattersphere",
      "Various stations",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game takes place in the 1980s?",
    options: [
      "GTA IV",
      "GTA Vice City",
      "GTA III",
      "GTA V",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the main currency used in GTA games?",
    options: [
      "Dollars",
      "Coins",
      "Gold",
      "Euros",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which company owns Rockstar Games?",
    options: [
      "Take-Two Interactive",
      "Sony",
      "EA",
      "Ubisoft",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the first mission of GTA San Andreas called?",
    options: [
      "Big Smoke",
      "The Green Sabre",
      "Home Coming",
      "In the Beginning",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which gang does CJ belong to?",
    options: [
      "Vagos",
      "Triads",
      "Grove Street Families",
      "Ballas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which color represents Grove Street Families?",
    options: [
      "Yellow",
      "Green",
      "Red",
      "Blue",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of the city in GTA San Andreas where CJ starts?",
    options: [
      "Vice City",
      "San Fierro",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who is Franklin's best friend in GTA V?",
    options: [
      "Jimmy",
      "Roman",
      "Lamar",
      "Trevor",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Trevor's company in GTA V?",
    options: [
      "Trevor Enterprises",
      "Trevor Philips Industries",
      "Los Santos Industries",
      "TP Industries",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which city is featured in GTA IV?",
    options: [
      "Vice City",
      "Liberty City",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is the main character of GTA IV?",
    options: [
      "Carl Johnson",
      "Tommy Vercetti",
      "Niko Bellic",
      "Franklin Clinton",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Niko Bellic's cousin?",
    options: [
      "Lamar",
      "Ryder",
      "Jimmy",
      "Roman",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced online multiplayer called GTA Online?",
    options: [
      "GTA San Andreas",
      "GTA IV",
      "Vice City",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of Michael's daughter in GTA V?",
    options: [
      "Denise",
      "Kate",
      "Tracy",
      "Amanda",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Michael's wife in GTA V?",
    options: [
      "Denise",
      "Michelle",
      "Maria",
      "Amanda",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which character is known for wearing a white tank top in GTA V?",
    options: [
      "Lester",
      "Trevor",
      "Franklin",
      "Michael",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the fictional social media platform in GTA V?",
    options: [
      "ChatBook",
      "Lifeinvader",
      "Faceworld",
      "SnapLife",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which company makes the in-game phones in GTA V?",
    options: [
      "Pear",
      "iFruit",
      "FruitOS",
      "Apple",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game features Tommy Vercetti?",
    options: [
      "GTA III",
      "GTA IV",
      "GTA Vice City",
      "GTA V",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What color is Tommy Vercetti's famous shirt?",
    options: [
      "Green",
      "Blue",
      "Black",
      "Pink",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which city is inspired by Miami?",
    options: [
      "Vice City",
      "San Fierro",
      "Liberty City",
      "Los Santos",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who betrays CJ in GTA San Andreas?",
    options: [
      "Sweet",
      "Woozie",
      "Big Smoke",
      "Cesar",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is CJ's full name?",
    options: [
      "Chris Johnson",
      "Charles Jackson",
      "Carl Johnson",
      "Cody Johnson",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which city is based on Las Vegas in GTA San Andreas?",
    options: [
      "San Fierro",
      "Liberty City",
      "Las Venturas",
      "Vice City",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which city is based on San Francisco in GTA San Andreas?",
    options: [
      "Las Venturas",
      "San Fierro",
      "Vice City",
      "Los Santos",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of CJ's brother?",
    options: [
      "Sweet",
      "Ryder",
      "Roman",
      "Big Smoke",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which gang is the enemy of Grove Street Families?",
    options: [
      "Aztecas",
      "Lost MC",
      "Ballas",
      "Triads",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who says the famous line 'Ah, shit, here we go again'?",
    options: [
      "Tommy Vercetti",
      "CJ",
      "Trevor",
      "Franklin",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of the motorcycle gang in GTA V?",
    options: [
      "The Lost MC",
      "Road Kings",
      "Vice Riders",
      "Street Demons",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which game came before GTA VI?",
    options: [
      "GTA IV",
      "GTA San Andreas",
      "GTA V",
      "GTA Online",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What type of game is GTA?",
    options: [
      "Puzzle",
      "Open-world action-adventure",
      "Sports",
      "Racing",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which company created the GTA series?",
    options: [
      "Rockstar Games",
      "Ubisoft",
      "Valve",
      "EA",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the full form of GTA?",
    options: [
      "Grand Truck Adventure",
      "Great Theft Adventure",
      "Grand Theft Auto",
      "Game Theft Arena",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game features Los Santos?",
    options: [
      "GTA Vice City",
      "GTA IV",
      "GTA III",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is one of the three protagonists in GTA V?",
    options: [
      "Trevor",
      "Niko",
      "Tommy",
      "CJ",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which character owns Chop in GTA V?",
    options: [
      "Lester",
      "Trevor",
      "Michael",
      "Franklin",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What animal is Chop?",
    options: [
      "Cat",
      "Horse",
      "Dog",
      "Parrot",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced Vice City?",
    options: [
      "GTA Vice City",
      "GTA V",
      "GTA III",
      "GTA IV",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the main character of GTA San Andreas?",
    options: [
      "Carl Johnson",
      "Niko Bellic",
      "Tommy Vercetti",
      "Franklin Clinton",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is CJ's gang called?",
    options: [
      "Vagos",
      "Ballas",
      "Triads",
      "Grove Street Families",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which color represents Grove Street?",
    options: [
      "Green",
      "Yellow",
      "Blue",
      "Red",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the female protagonist of GTA VI?",
    options: [
      "Amanda",
      "Lucia",
      "Denise",
      "Maria",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of GTA VI's state?",
    options: [
      "San Andreas",
      "Leonida",
      "Liberty",
      "Alderney",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which city returns in GTA VI?",
    options: [
      "Liberty City",
      "Vice City",
      "San Fierro",
      "Los Santos",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game stars Niko Bellic?",
    options: [
      "GTA V",
      "GTA IV",
      "GTA III",
      "Vice City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is Niko's cousin?",
    options: [
      "Sweet",
      "Ryder",
      "Lamar",
      "Roman",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced online multiplayer as GTA Online?",
    options: [
      "San Andreas",
      "GTA V",
      "GTA IV",
      "Vice City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of Michael's son?",
    options: [
      "Tracey",
      "Jimmy",
      "Lamar",
      "Roman",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of Michael's daughter?",
    options: [
      "Amanda",
      "Maria",
      "Denise",
      "Tracey",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is Michael's wife?",
    options: [
      "Maria",
      "Denise",
      "Amanda",
      "Michelle",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA protagonist loves causing chaos?",
    options: [
      "CJ",
      "Franklin",
      "Michael",
      "Trevor",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which company publishes GTA games?",
    options: [
      "Nintendo",
      "Take-Two Interactive",
      "Microsoft",
      "Sony",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA city is based on New York?",
    options: [
      "Vice City",
      "Los Santos",
      "Las Venturas",
      "Liberty City",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA city is based on Miami?",
    options: [
      "San Fierro",
      "Vice City",
      "Liberty City",
      "Los Santos",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA city is based on Las Vegas?",
    options: [
      "Las Venturas",
      "Vice City",
      "Los Santos",
      "Liberty City",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA city is based on San Francisco?",
    options: [
      "Vice City",
      "San Fierro",
      "Liberty City",
      "Los Santos",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who says 'Ah, shit, here we go again'?",
    options: [
      "Trevor",
      "Franklin",
      "Tommy",
      "CJ",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Trevor's last name?",
    options: [
      "Johnson",
      "Clinton",
      "Bellic",
      "Philips",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Franklin's last name?",
    options: [
      "Vercetti",
      "Johnson",
      "Philips",
      "Clinton",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game came out before GTA VI?",
    options: [
      "San Andreas",
      "Vice City",
      "GTA IV",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which game engine is used in modern GTA games?",
    options: [
      "RAGE",
      "CryEngine",
      "Unity",
      "Unreal Engine",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of Franklin's friend?",
    options: [
      "Jimmy",
      "Roman",
      "Big Smoke",
      "Lamar",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which console first received GTA V?",
    options: [
      "PS5",
      "Nintendo Switch",
      "PS3 and Xbox 360",
      "PS2",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of the social media company in GTA V?",
    options: [
      "Faceworld",
      "SnapLife",
      "ChatBook",
      "Lifeinvader",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What brand of smartphone exists in GTA V?",
    options: [
      "iFruit",
      "Galaxy",
      "Pear",
      "Apple",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the protagonist of GTA Vice City?",
    options: [
      "Franklin",
      "Tommy Vercetti",
      "Niko",
      "CJ",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is Tommy Vercetti's famous shirt color?",
    options: [
      "Blue",
      "Black",
      "Red",
      "Green",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game is set in the 1980s?",
    options: [
      "GTA V",
      "GTA Vice City",
      "GTA IV",
      "GTA III",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the currency in GTA games?",
    options: [
      "Coins",
      "Euro",
      "Gold",
      "Dollar",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of Michael's family surname?",
    options: [
      "De Santa",
      "Clinton",
      "Johnson",
      "Bellic",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which city does CJ start in?",
    options: [
      "San Fierro",
      "Las Venturas",
      "Vice City",
      "Los Santos",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is CJ's brother?",
    options: [
      "Roman",
      "Sweet",
      "Big Smoke",
      "Ryder",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which gang is the enemy of Grove Street?",
    options: [
      "Ballas",
      "Lost MC",
      "Triads",
      "Aztecas",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of the dog in GTA V?",
    options: [
      "Buddy",
      "Chop",
      "Rocky",
      "Max",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game features three playable protagonists?",
    options: [
      "GTA V",
      "San Andreas",
      "GTA IV",
      "Vice City",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced Lucia?",
    options: [
      "GTA V",
      "GTA IV",
      "GTA VI",
      "Vice",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which company created the Red Dead Redemption series?",
    options: [
      "Rockstar Games",
      "EA",
      "Ubisoft",
      "Valve",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of Michael's therapist in GTA V?",
    options: [
      "Dr. Friedlander",
      "Dr. House",
      "Dr. Brown",
      "Dr. Smith",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is Trevor's best friend in GTA V?",
    options: [
      "Franklin",
      "Wade",
      "Lester",
      "Michael",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which character plans most of the heists in GTA V?",
    options: [
      "Lamar",
      "Lester",
      "Trevor",
      "Jimmy",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of the jewelry store robbed in GTA V?",
    options: [
      "Binco",
      "Sub Urban",
      "Ponsonbys",
      "Vangelico",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the desert area in GTA V?",
    options: [
      "Sandy Desert",
      "Red Desert",
      "Vice Desert",
      "Grand Senora Desert",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the military base in GTA V?",
    options: [
      "Camp Leonida",
      "Area 69",
      "Fort Carson",
      "Fort Zancudo",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the tallest mountain in GTA V?",
    options: [
      "Mount Gordo",
      "Mount Chiliad",
      "Mount Leonida",
      "Mount Josiah",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which company makes the in-game internet browser in GTA V?",
    options: [
      "Eyefind",
      "Lifeinvader",
      "iFruit",
      "Snapmatic",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of GTA V's in-game photo app?",
    options: [
      "Instagram",
      "Snapmatic",
      "QuickPic",
      "PhotoBook",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is Franklin's aunt in GTA V?",
    options: [
      "Patricia",
      "Amanda",
      "Denise",
      "Tracey",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which character loves yoga in GTA V?",
    options: [
      "Trevor",
      "Michael",
      "Lester",
      "Franklin",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced the character CJ?",
    options: [
      "GTA San Andreas",
      "GTA IV",
      "GTA Vice City",
      "GTA III",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of CJ's sister?",
    options: [
      "Kendl",
      "Maria",
      "Denise",
      "Catalina",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is CJ's friend that loves food?",
    options: [
      "Ryder",
      "Big Smoke",
      "Woozie",
      "Sweet",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What vehicle does CJ learn to fly in San Andreas?",
    options: [
      "Jet",
      "Helicopter",
      "Airplane",
      "Hot Air Balloon",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who is the blind leader of the Triads in San Andreas?",
    options: [
      "Woozie",
      "Big Smoke",
      "Ryder",
      "Sweet",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced Liberty City in 3D?",
    options: [
      "GTA III",
      "GTA IV",
      "GTA V",
      "Vice City",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of Niko Bellic's love interest in GTA IV?",
    options: [
      "Amanda",
      "Michelle",
      "Maria",
      "Kate",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which country inspired the setting of GTA VI?",
    options: [
      "Brazil",
      "United States",
      "Mexico",
      "Canada",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which state inspired Leonida in GTA VI?",
    options: [
      "California",
      "Texas",
      "Florida",
      "Nevada",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which city inspired Vice City?",
    options: [
      "New York",
      "Chicago",
      "Miami",
      "Las Vegas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA protagonist wears a green jacket?",
    options: [
      "Trevor",
      "Michael",
      "Tommy",
      "Franklin",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What color is Franklin's car in many artworks?",
    options: [
      "Blue",
      "Green",
      "White",
      "Black",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which company made GTA Online?",
    options: [
      "Rockstar Games",
      "Sony",
      "Ubisoft",
      "EA",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game has the biggest map before GTA VI?",
    options: [
      "GTA III",
      "GTA IV",
      "Vice City",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the prison in GTA V?",
    options: [
      "Fort Prison",
      "Bolingbroke Penitentiary",
      "Vice Penitentiary",
      "Liberty Prison",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which character wears glasses and uses a cane in GTA V?",
    options: [
      "Michael",
      "Jimmy",
      "Trevor",
      "Lester",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the town where Trevor lives?",
    options: [
      "Paleto Bay",
      "Vinewood",
      "Sandy Shores",
      "Rockford Hills",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the Hollywood-inspired area in GTA V called?",
    options: [
      "Vinewood",
      "Mirror Park",
      "Downtown",
      "Del Perro",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the famous sign on the hills in GTA V?",
    options: [
      "San Andreas",
      "Vinewood",
      "Los Santos",
      "Hollywood",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced motorcycles for the first time in 3D?",
    options: [
      "GTA III",
      "GTA V",
      "GTA IV",
      "GTA Vice City",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is Franklin's girlfriend in GTA V?",
    options: [
      "Amanda",
      "Kate",
      "Denise",
      "Tanisha",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA character often says 'You forget a thousand things every day'?",
    options: [
      "Franklin",
      "Michael",
      "Trevor",
      "Lester",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of Michael's boat?",
    options: [
      "Sea Rider",
      "Speedster",
      "Did Somebody Say Yoga?",
      "Marquis",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced the smartphone?",
    options: [
      "GTA IV",
      "GTA III",
      "San Andreas",
      "Vice City",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the in-game internet called in GTA V?",
    options: [
      "Eyefind",
      "LifeNet",
      "SnapWeb",
      "GoWeb",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA protagonist is a retired bank robber?",
    options: [
      "Michael",
      "Niko",
      "Franklin",
      "CJ",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the youngest of the three GTA V protagonists?",
    options: [
      "Michael",
      "Franklin",
      "Trevor",
      "Lester",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA city is inspired by Los Angeles?",
    options: [
      "Liberty City",
      "Vice City",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of GTA V's stock market website?",
    options: [
      "Lifeinvader",
      "Eyefind",
      "BAWSAQ",
      "Dynasty",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which website is used to buy properties in GTA V?",
    options: [
      "Lifeinvader",
      "Dynasty 8",
      "BAWSAQ",
      "Eyefind",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the name of the social network in GTA V?",
    options: [
      "Lifeinvader",
      "SnapChat",
      "X",
      "FaceBook",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced underwater exploration?",
    options: [
      "Vice City",
      "GTA V",
      "GTA III",
      "San Andreas",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game has a female protagonist for the first time in the HD universe?",
    options: [
      "GTA IV",
      "GTA V",
      "Vice City",
      "GTA VI",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the release year of GTA V?",
    options: [
      "2014",
      "2012",
      "2013",
      "2015",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the release year of GTA IV?",
    options: [
      "2008",
      "2009",
      "2007",
      "2010",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the release year of GTA San Andreas?",
    options: [
      "2004",
      "2005",
      "2003",
      "2006",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the release year of GTA Vice City?",
    options: [
      "2001",
      "2002",
      "2004",
      "2003",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the release year of GTA III?",
    options: [
      "2003",
      "2000",
      "2002",
      "2001",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What color is the Ballas gang known for?",
    options: [
      "Purple",
      "Blue",
      "Red",
      "Green",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What color is the Vagos gang known for?",
    options: [
      "Purple",
      "Blue",
      "Green",
      "Yellow",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is Franklin's friend that often gets into trouble?",
    options: [
      "Wade",
      "Roman",
      "Jimmy",
      "Lamar",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which city is featured in GTA III?",
    options: [
      "Liberty City",
      "Vice City",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the protagonist of GTA III?",
    options: [
      "CJ",
      "Niko",
      "Claude",
      "Tommy",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is Claude known for?",
    options: [
      "Being a cop",
      "Being a pilot",
      "Being a racer",
      "Being silent",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced swimming?",
    options: [
      "GTA Vice City",
      "GTA IV",
      "GTA III",
      "GTA San Andreas",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the casino city in San Andreas?",
    options: [
      "Los Santos",
      "Las Venturas",
      "Liberty City",
      "Vice City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which character likes to work out in San Andreas?",
    options: [
      "Claude",
      "Niko",
      "Tommy",
      "CJ",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced bicycles?",
    options: [
      "GTA III",
      "GTA San Andreas",
      "Vice City",
      "GTA IV",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is Trevor's friend that lives with him?",
    options: [
      "Lamar",
      "Roman",
      "Jimmy",
      "Wade",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which city contains Grove Street?",
    options: [
      "Los Santos",
      "Vice City",
      "Liberty City",
      "Las Venturas",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of the airport in GTA V?",
    options: [
      "Los Santos International Airport",
      "Liberty Airport",
      "San Andreas Airport",
      "Vice Airport",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which character wears a white suit in GTA Vice City?",
    options: [
      "Tommy Vercetti",
      "Franklin",
      "Niko",
      "CJ",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced heists?",
    options: [
      "GTA V",
      "San Andreas",
      "Vice City",
      "GTA IV",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of the amusement pier in GTA V?",
    options: [
      "Del Perro Pier",
      "Pleasure Pier",
      "Ocean Pier",
      "Vice Pier",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which character is an expert hacker in GTA V?",
    options: [
      "Trevor",
      "Lester",
      "Jimmy",
      "Franklin",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced first-person mode?",
    options: [
      "Vice City",
      "GTA IV",
      "GTA V",
      "San Andreas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Franklin's first house area?",
    options: [
      "Sandy Shores",
      "Rockford Hills",
      "Strawberry",
      "Vinewood",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who is the leader of Grove Street Families?",
    options: [
      "Ryder",
      "CJ",
      "Big Smoke",
      "Sweet",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA protagonist came from Eastern Europe?",
    options: [
      "CJ",
      "Franklin",
      "Tommy",
      "Niko Bellic",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced internet cafés?",
    options: [
      "San Andreas",
      "GTA V",
      "Vice City",
      "GTA IV",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the giant mountain mystery in GTA V?",
    options: [
      "Mount Chiliad Mystery",
      "Alien Mountain",
      "Ghost Peak",
      "Bigfoot Mystery",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which animal can be hunted in GTA V?",
    options: [
      "Elephant",
      "Deer",
      "Tiger",
      "Lion",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced scuba diving?",
    options: [
      "San Andreas",
      "GTA V",
      "GTA III",
      "Vice City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is the first playable character in GTA V?",
    options: [
      "Lester",
      "Franklin",
      "Michael",
      "Trevor",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced weapon customization?",
    options: [
      "Vice City",
      "San Andreas",
      "GTA IV",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the lake near Mount Chiliad?",
    options: [
      "Alamo Sea",
      "Leonida Lake",
      "Blue Lake",
      "Mirror Lake",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of Trevor's airfield?",
    options: [
      "McKenzie Field",
      "Desert Airfield",
      "Trevor Airfield",
      "Sandy Airport",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced parachuting?",
    options: [
      "GTA III",
      "Vice City",
      "GTA San Andreas",
      "GTA IV",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of the golf club in GTA V?",
    options: [
      "Vinewood Golf Club",
      "Los Santos Golf Club",
      "Rockford Golf Club",
      "Vice Golf Club",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA city has a large beach called Vespucci Beach?",
    options: [
      "Liberty City",
      "Las Venturas",
      "Vice City",
      "Los Santos",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the rich neighborhood in GTA V?",
    options: [
      "Grove Street",
      "Strawberry",
      "Sandy Shores",
      "Rockford Hills",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game introduced the ability to switch characters?",
    options: [
      "Vice City",
      "San Andreas",
      "GTA V",
      "GTA IV",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA protagonist owns a trailer home?",
    options: [
      "Trevor",
      "Michael",
      "Franklin",
      "CJ",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is the police officer that corrupts CJ?",
    options: [
      "Officer Pulaski",
      "Officer Frank",
      "Officer Tenpenny",
      "Officer Hernandez",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who voiced Officer Tenpenny?",
    options: [
      "Ice Cube",
      "Samuel L. Jackson",
      "Dwayne Johnson",
      "Will Smith",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced gyms?",
    options: [
      "GTA San Andreas",
      "GTA IV",
      "GTA III",
      "Vice City",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What food restaurant is popular in GTA San Andreas?",
    options: [
      "Burger King",
      "Cluckin' Bell",
      "McDonald's",
      "Subway",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which fast-food chain appears in most GTA games?",
    options: [
      "Domino's",
      "Pizza Hut",
      "Cluckin' Bell",
      "KFC",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced stock markets?",
    options: [
      "Vice City",
      "GTA IV",
      "GTA V",
      "San Andreas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced buying businesses?",
    options: [
      "GTA III",
      "GTA Vice City",
      "GTA V",
      "GTA IV",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA protagonist can grow fat or muscular?",
    options: [
      "CJ",
      "Tommy",
      "Franklin",
      "Niko",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game introduced train driving missions?",
    options: [
      "GTA IV",
      "Vice City",
      "GTA III",
      "GTA San Andreas",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who says 'All we had to do was follow the damn train'?",
    options: [
      "CJ",
      "Ryder",
      "Big Smoke",
      "Sweet",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA game introduced underwater treasure hunting?",
    options: [
      "Vice City",
      "GTA IV",
      "GTA V",
      "GTA III",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of the movie studio in GTA V?",
    options: [
      "Majestic Pictures",
      "Richards Majestic",
      "Los Santos Films",
      "Vinewood Studio",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced random events?",
    options: [
      "GTA III",
      "GTA V",
      "Vice City",
      "San Andreas",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game introduced playable animals in special modes?",
    options: [
      "Vice City",
      "GTA IV",
      "San Andreas",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the theme park area in GTA V?",
    options: [
      "Paleto Bay",
      "Vinewood Hills",
      "Mirror Park",
      "Del Perro Pier",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the title of the next Grand Theft Auto game?",
    options: [
      "GTA VI",
      "GTA V 2",
      "Vice City 2",
      "Grand Theft Auto Online",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the fictional state in GTA VI called?",
    options: [
      "Alderney",
      "North Yankton",
      "Leonida",
      "San Andreas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which real-life state inspired Leonida?",
    options: [
      "Texas",
      "Nevada",
      "California",
      "Florida",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the name of the male protagonist shown in GTA VI trailers?",
    options: [
      "Franklin",
      "Tommy",
      "Jason",
      "Trevor",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which company develops GTA VI?",
    options: [
      "EA",
      "Valve",
      "Ubisoft",
      "Rockstar Games",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which company publishes GTA VI?",
    options: [
      "Nintendo",
      "Take-Two Interactive",
      "Sony",
      "Microsoft",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which trailer broke YouTube records shortly after release?",
    options: [
      "GTA V Trailer",
      "GTA IV Trailer",
      "Vice City Trailer",
      "GTA VI Trailer 1",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What kind of relationship do Lucia and Jason appear to have?",
    options: [
      "Partners in crime",
      "Business rivals",
      "Brothers",
      "Police partners",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which famous U.S. city inspired Vice City?",
    options: [
      "Miami",
      "New York",
      "Chicago",
      "Las Vegas",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which social media style clips appear in the GTA VI trailer?",
    options: [
      "Emails",
      "Podcasts",
      "Newspapers",
      "Short videos",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which animal appears in the GTA VI trailer?",
    options: [
      "Panda",
      "Elephant",
      "Tiger",
      "Alligator",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What type of game is GTA VI?",
    options: [
      "Open-world action-adventure",
      "Strategy",
      "Puzzle",
      "Sports",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which game comes before GTA VI in the main series?",
    options: [
      "GTA Vice City",
      "GTA IV",
      "GTA V",
      "GTA San Andreas",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which console generation will receive GTA VI first?",
    options: [
      "PS4 and Xbox One",
      "PS5 and Xbox Series X|S",
      "Nintendo Switch",
      "Mobile",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which city is known for its beaches in GTA VI?",
    options: [
      "Liberty City",
      "Las Venturas",
      "Vice City",
      "Los Santos",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which trailer introduced Lucia to fans?",
    options: [
      "Gameplay Demo",
      "Trailer 1",
      "Story Trailer",
      "Trailer 2",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is one major theme shown in GTA VI trailers?",
    options: [
      "Space travel",
      "Magic",
      "Medieval warfare",
      "Crime",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What color is commonly associated with GTA VI branding?",
    options: [
      "Red and Blue",
      "Pink and Purple",
      "Black and White",
      "Green and Yellow",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which engine powers modern Rockstar games like GTA VI?",
    options: [
      "Unity",
      "Frostbite",
      "RAGE",
      "Unreal Engine",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which protagonist in GTA VI is female?",
    options: [
      "Amanda",
      "Lucia",
      "Tracey",
      "Denise",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which protagonist in GTA VI is male?",
    options: [
      "CJ",
      "Jason",
      "Trevor",
      "Niko",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What kind of environment is Leonida inspired by?",
    options: [
      "Desert",
      "Snowy",
      "Mountain",
      "Tropical",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA VI location appears to contain swamps?",
    options: [
      "Alderney",
      "Liberty State",
      "San Andreas",
      "Leonida",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which animal is commonly found in Florida and appears in GTA VI?",
    options: [
      "Alligator",
      "Camel",
      "Penguin",
      "Polar Bear",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA VI protagonist has been shown wearing prison clothes?",
    options: [
      "Michael",
      "Lucia",
      "Jason",
      "Tommy",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which city in GTA VI is inspired by Miami?",
    options: [
      "Vice City",
      "Liberty City",
      "Las Venturas",
      "Los Santos",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What kind of vehicles are shown in GTA VI trailers?",
    options: [
      "Cars, boats, and aircraft",
      "Only bicycles",
      "Only tanks",
      "Only trains",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA VI protagonist appears in most promotional artwork?",
    options: [
      "CJ",
      "Niko",
      "Trevor",
      "Lucia",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What genre does GTA VI belong to?",
    options: [
      "Racing",
      "Simulation",
      "Strategy",
      "Action-adventure",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which social media platform inspired some GTA VI trailer clips?",
    options: [
      "Gmail",
      "LinkedIn",
      "TikTok",
      "Wikipedia",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which environment is heavily featured in GTA VI?",
    options: [
      "Volcanoes",
      "Beaches",
      "Snow fields",
      "Space stations",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which season appears in the first GTA VI trailer?",
    options: [
      "Autumn",
      "Summer",
      "Winter",
      "Spring",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is Vice City famous for?",
    options: [
      "Castles",
      "Deserts",
      "Nightlife and beaches",
      "Snow and mountains",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA VI protagonist appears to enjoy thrill-seeking activities?",
    options: [
      "Jimmy",
      "Lester",
      "Jason",
      "Roman",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the likely setting of GTA VI?",
    options: [
      "Modern day",
      "Medieval era",
      "Ancient times",
      "Future space",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which U.S. region inspired GTA VI's setting?",
    options: [
      "Western Europe",
      "Northern Canada",
      "South America",
      "Southeastern United States",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA VI trailer scene became a popular meme?",
    options: [
      "A dragon",
      "The alligator in a store",
      "A flying tank",
      "A spaceship",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is a major feature expected in GTA VI?",
    options: [
      "Linear levels",
      "Turn-based combat",
      "2D graphics",
      "A large open world",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which color dominates Vice City's neon style?",
    options: [
      "Gray",
      "Brown",
      "Pink",
      "Orange",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA VI protagonist appears first in Trailer 1?",
    options: [
      "Trevor",
      "Franklin",
      "Jason",
      "Lucia",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What type of weather is expected in Leonida?",
    options: [
      "Sunny and tropical",
      "Blizzards",
      "Constant snow",
      "Sandstorms",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which state in GTA VI contains Vice City?",
    options: [
      "North Yankton",
      "Leonida",
      "San Andreas",
      "Liberty",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which type of watercraft appears in GTA VI trailers?",
    options: [
      "Airboats",
      "Submarines only",
      "Cruise ships only",
      "Pirate ships",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is one of GTA VI's biggest selling points?",
    options: [
      "Turn-based gameplay",
      "No vehicles",
      "Its massive open world",
      "Black and white graphics",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which Rockstar franchise does GTA VI belong to?",
    options: [
      "Grand Theft Auto",
      "Red Dead Redemption",
      "Bully",
      "Max Payne",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What type of crime activities are expected in GTA VI?",
    options: [
      "Robberies and heists",
      "Only fishing",
      "Only sports",
      "Only farming",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which location style is heavily shown in GTA VI trailers?",
    options: [
      "Frozen tundra",
      "Volcanoes",
      "Ancient ruins",
      "Neon city streets",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V character can purchase the Downtown Cab Co.?",
    options: [
      "Michael",
      "Franklin",
      "Lester",
      "Trevor",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V protagonist can take part in stock-market assassination strategies?",
    options: [
      "Michael",
      "Lamar",
      "Franklin",
      "Trevor",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Franklin's original vehicle in GTA V?",
    options: [
      "Buffalo",
      "F620",
      "Sultan",
      "Banshee",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which property gives Trevor access to hangar-related activities?",
    options: [
      "Vanilla Unicorn",
      "Los Santos Customs",
      "Sandy Shores Airfield",
      "Hen House",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V mission is associated with the first major jewelry-store heist?",
    options: [
      "The Jewel Store Job",
      "Blitz Play",
      "The Big Score",
      "The Paleto Score",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who recruits Franklin for the jewelry-store heist?",
    options: [
      "Michael",
      "Trevor",
      "Lamar",
      "Lester",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V protagonist lives in Sandy Shores for much of the story?",
    options: [
      "Lester",
      "Franklin",
      "Michael",
      "Trevor",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Trevor's surname in GTA V?",
    options: [
      "Bellic",
      "De Santa",
      "Clinton",
      "Philips",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which character runs the Vanilla Unicorn in GTA V?",
    options: [
      "Trevor",
      "Michael",
      "Lester",
      "Franklin",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V character is associated with the FIB agent Dave Norton?",
    options: [
      "Lamar",
      "Trevor",
      "Michael",
      "Franklin",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V character is a skilled getaway driver and street racer?",
    options: [
      "Michael",
      "Lester",
      "Dave",
      "Franklin",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V protagonist is particularly skilled at flying?",
    options: [
      "Franklin",
      "Lamar",
      "Trevor",
      "Michael",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which special ability slows time while driving?",
    options: [
      "Franklin's",
      "Michael's",
      "Lester's",
      "Trevor's",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which special ability lets Michael slow time during gunfights?",
    options: [
      "Dead Eye-style focus",
      "Rage",
      "Driving Focus",
      "Hacking",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V protagonist's special ability increases damage and reduces incoming damage?",
    options: [
      "Michael",
      "Franklin",
      "Trevor",
      "Jimmy",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V character has a close relationship with Chop?",
    options: [
      "Trevor",
      "Michael",
      "Franklin",
      "Lester",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Franklin's aunt?",
    options: [
      "Tracey",
      "Patricia",
      "Denise",
      "Amanda",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V character owns a mansion in Vinewood Hills?",
    options: [
      "Lamar",
      "Franklin",
      "Trevor",
      "Michael",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V heist involves a military convoy and heavy equipment?",
    options: [
      "The Jewel Store Job",
      "Blitz Play",
      "The Bureau Raid",
      "The Paleto Score",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V heist takes place partly at a bank in Paleto Bay?",
    options: [
      "Blitz Play",
      "The Paleto Score",
      "The Big Score",
      "The Humane Labs Raid",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V heist is considered the story's final major heist?",
    options: [
      "Blitz Play",
      "The Big Score",
      "The Paleto Score",
      "The Jewel Store Job",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which character is central to planning GTA V heists?",
    options: [
      "Lester Crest",
      "Wade Hebert",
      "Dave Norton",
      "Ron Jakowski",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V location is a large military installation?",
    options: [
      "Fort Zancudo",
      "Bolingbroke Penitentiary",
      "Los Santos International Airport",
      "Paleto Forest",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V desert town is associated with Trevor and Ron?",
    options: [
      "Grapeseed",
      "Chumash",
      "Harmony",
      "Sandy Shores",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V radio station is strongly associated with hip-hop?",
    options: [
      "Radio Los Santos",
      "Non-Stop-Pop FM",
      "Vinewood Boulevard Radio",
      "Kult FM",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V website is used to purchase vehicles online?",
    options: [
      "Warstock News",
      "Southern San Andreas Super Autos",
      "Lifeinvader",
      "Dynasty 8",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V website specializes in military and weaponized vehicles?",
    options: [
      "Elitas Travel",
      "Warstock Cache & Carry",
      "Legendary Motorsport",
      "DockTease",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V website is associated with boats?",
    options: [
      "Dynasty 8",
      "DockTease",
      "Elitas Travel",
      "Warstock Cache & Carry",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V website is associated with aircraft?",
    options: [
      "Elitas Travel",
      "Southern San Andreas Super Autos",
      "Legendary Motorsport",
      "DockTease",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V website is used for many luxury vehicles?",
    options: [
      "Legendary Motorsport",
      "Dynasty 8",
      "Eyefind",
      "DockTease",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA V property website is used to buy apartments and garages?",
    options: [
      "BAWSAQ",
      "Lifeinvader",
      "Dynasty 8",
      "Warstock",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of the Los Santos police department abbreviation?",
    options: [
      "FIB",
      "LSPD",
      "NOOSE",
      "IAA",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What organization is commonly represented by the acronym FIB in GTA V?",
    options: [
      "Federal Investigation Bureau",
      "Free Investigation Bureau",
      "Federal Intelligence Branch",
      "Financial Investigation Bureau",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What organization is the FIB's rival in GTA V's story?",
    options: [
      "IAA",
      "Merryweather",
      "NOOSE",
      "LSPD",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which private military company appears in GTA V?",
    options: [
      "Armed Forces Inc.",
      "Los Santos Defense",
      "Merryweather Security",
      "Cluckin' Bell Security",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V character is associated with the Merryweather heist storyline?",
    options: [
      "Lamar",
      "Jimmy",
      "Trevor",
      "Tanisha",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V location is famous for the Vinewood Sign?",
    options: [
      "Chumash",
      "Paleto Bay",
      "Sandy Shores",
      "Vinewood Hills",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V neighborhood is known for its luxury homes and celebrity atmosphere?",
    options: [
      "Harmony",
      "Vinewood Hills",
      "Davis",
      "Grapeseed",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V beach is located on the western side of Los Santos?",
    options: [
      "Paleto Beach",
      "North Chumash Beach",
      "Vespucci Beach",
      "Alamo Beach",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V location is a rural coastal town north of Los Santos?",
    options: [
      "Vespucci",
      "Davis",
      "Strawberry",
      "Paleto Bay",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V area contains the Alamo Sea?",
    options: [
      "Rockford Hills",
      "Downtown Los Santos",
      "Blaine County",
      "Vinewood",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which mountain is central to one of GTA V's biggest mysteries?",
    options: [
      "Mount Haan",
      "Mount Josiah",
      "Mount Gordo",
      "Mount Chiliad",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA V cable-car route reaches the top of Mount Chiliad?",
    options: [
      "Blaine Rail",
      "Mount Chiliad Cable Car",
      "Paleto Lift",
      "Vinewood Tram",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V animal is commonly used in hunting activities?",
    options: [
      "Lion",
      "Camel",
      "Deer",
      "Elephant",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V activity lets players compete in a golf course?",
    options: [
      "Tennis",
      "Golf",
      "Triathlon",
      "Darts",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V activity can Franklin, Michael, and Trevor all participate in?",
    options: [
      "Basketball",
      "Tennis",
      "Baseball",
      "Boxing",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA V character can practice yoga with Michael?",
    options: [
      "Ron Jakowski",
      "Lamar Davis",
      "Fabien LaRouche",
      "Wade Hebert",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA V character is Michael's therapist?",
    options: [
      "Dr. Klebitz",
      "Dr. Haines",
      "Dr. Friedlander",
      "Dr. Norton",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA IV borough is based largely on Brooklyn?",
    options: [
      "Dukes",
      "Bohan",
      "Broker",
      "Algonquin",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA IV borough is based largely on Manhattan?",
    options: [
      "Broker",
      "Bohan",
      "Algonquin",
      "Dukes",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA IV borough is based largely on Queens?",
    options: [
      "Bohan",
      "Dukes",
      "Algonquin",
      "Broker",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA IV borough is based largely on the Bronx?",
    options: [
      "Bohan",
      "Dukes",
      "Algonquin",
      "Broker",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA IV borough is based largely on Staten Island?",
    options: [
      "Dukes",
      "Broker",
      "Alderney",
      "Bohan",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is the name of Niko Bellic's cousin in GTA IV?",
    options: [
      "Brucie Kibbutz",
      "Dwayne Forge",
      "Roman Bellic",
      "Little Jacob",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA IV character is known for selling weapons and speaking Jamaican patois?",
    options: [
      "Little Jacob",
      "Brucie",
      "Packie",
      "Roman",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA IV character is obsessed with fitness and cars?",
    options: [
      "Phil Bell",
      "Dwayne Forge",
      "Little Jacob",
      "Brucie Kibbutz",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA IV character is associated with the McReary family?",
    options: [
      "Packie McReary",
      "Vlad Glebov",
      "Brucie Kibbutz",
      "Roman Bellic",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the name of Niko's first safehouse in GTA IV?",
    options: [
      "Algonquin Apartment",
      "Broker Safehouse",
      "Bohan Flat",
      "Alderney House",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA IV character is Niko's girlfriend who works with the IAA?",
    options: [
      "Carmen",
      "Kate",
      "Michelle",
      "Kiki",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA IV location is home to the Statue of Happiness?",
    options: [
      "Firefly Island",
      "Charge Island",
      "Colony Island",
      "Happiness Island",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA IV island contains the main financial district?",
    options: [
      "Dukes",
      "Algonquin",
      "Bohan",
      "Broker",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA San Andreas city is based on San Francisco?",
    options: [
      "San Fierro",
      "Angel Pine",
      "Los Santos",
      "Las Venturas",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA San Andreas city is based on Las Vegas?",
    options: [
      "Los Santos",
      "Palomino Creek",
      "Las Venturas",
      "San Fierro",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA San Andreas city is based on Los Angeles?",
    options: [
      "Dillimore",
      "Las Venturas",
      "San Fierro",
      "Los Santos",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA San Andreas character is CJ's older brother?",
    options: [
      "Ryder",
      "Cesar",
      "Sweet",
      "Big Smoke",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA San Andreas character is associated with the Aztecas?",
    options: [
      "Cesar Vialpando",
      "Sweet",
      "Wu Zi Mu",
      "Ryder",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA San Andreas character is known as Woozie?",
    options: [
      "Wu Zi Mu",
      "Mike Toreno",
      "The Truth",
      "Cesar Vialpando",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA San Andreas character is the leader of the Triads in San Fierro?",
    options: [
      "Wu Zi Mu",
      "Big Smoke",
      "Ryder",
      "Sweet",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA San Andreas character owns the Four Dragons Casino?",
    options: [
      "Cesar Vialpando",
      "Zero",
      "Wu Zi Mu",
      "Sweet",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA San Andreas character is a conspiracy-loving hippie?",
    options: [
      "Toreno",
      "Cesar",
      "Woozie",
      "The Truth",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA San Andreas character becomes CJ's girlfriend and is linked to the countryside?",
    options: [
      "Barbara",
      "Catalina",
      "Denise",
      "Kendl",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA San Andreas character is a skilled mechanic and street racer?",
    options: [
      "Big Smoke",
      "Tenpenny",
      "Ryder",
      "Cesar Vialpando",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA San Andreas mission famously involves the train chase?",
    options: [
      "End of the Line",
      "Wrong Side of the Tracks",
      "Just Business",
      "Green Sabre",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA San Andreas mission is associated with the betrayal of Grove Street?",
    options: [
      "Reuniting the Families",
      "The Green Sabre",
      "Learning to Fly",
      "Wear Flowers in Your Hair",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA San Andreas location is known for the Gant Bridge?",
    options: [
      "Las Venturas",
      "San Fierro",
      "Los Santos",
      "Red County",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA San Andreas property is a casino owned by Woozie's group?",
    options: [
      "Four Dragons Casino",
      "Caligula's Palace",
      "The Camel's Toe",
      "The Emerald Isle",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA Vice City location is Tommy Vercetti's main mansion?",
    options: [
      "Malibu Club",
      "Print Works",
      "Ocean View Hotel",
      "Vercetti Estate",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA Vice City property is central to the game's nightclub business?",
    options: [
      "Malibu Club",
      "Film Studio",
      "Sunshine Autos",
      "Boatyard",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA Vice City business allows Tommy to operate a film studio?",
    options: [
      "Vercetti Estate",
      "InterGlobal Films",
      "Kaufman Cabs",
      "Print Works",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA Vice City property is connected to printing counterfeit money?",
    options: [
      "Pole Position Club",
      "Boatyard",
      "Print Works",
      "Malibu Club",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA Vice City business is a car showroom?",
    options: [
      "Kaufman Cabs",
      "Cherry Popper",
      "Boatyard",
      "Sunshine Autos",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA Vice City business is associated with ice-cream distribution?",
    options: [
      "Sunshine Autos",
      "Cherry Popper Ice Cream Factory",
      "Print Works",
      "InterGlobal Films",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA Vice City character is Tommy's lawyer?",
    options: [
      "Ken Rosenberg",
      "Lance Vance",
      "Sonny Forelli",
      "Avery Carrington",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA Vice City character becomes Tommy's partner before their conflict?",
    options: [
      "Lance Vance",
      "Ken Rosenberg",
      "Phil Cassidy",
      "Avery Carrington",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA Vice City character owns the Malibu Club?",
    options: [
      "Ken Rosenberg",
      "Avery Carrington",
      "Sonny Forelli",
      "Kent Paul",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA Vice City character is a property developer who gives Tommy construction-related jobs?",
    options: [
      "Lance Vance",
      "Ricardo Diaz",
      "Avery Carrington",
      "Kent Paul",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA Vice City character is Tommy's main rival before the final confrontation?",
    options: [
      "Ken Rosenberg",
      "Sonny Forelli",
      "Avery Carrington",
      "Phil Cassidy",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA III protagonist is famously silent?",
    options: [
      "Vincenzo Cilli",
      "Toni Cipriani",
      "Ray Machowski",
      "Claude",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA III city is divided into Portland, Staunton Island, and Shoreside Vale?",
    options: [
      "Vice City",
      "Los Santos",
      "Liberty City",
      "San Fierro",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA III character is the head of the Yakuza?",
    options: [
      "Asuka Kasen",
      "Maria Latore",
      "Misty",
      "Catalina",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA III character betrays Claude at the beginning of the game?",
    options: [
      "Misty",
      "Maria",
      "Catalina",
      "Asuka",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA III character is Claude's girlfriend who later becomes a major antagonist?",
    options: [
      "Salvatore",
      "Maria",
      "Catalina",
      "Asuka",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA III character is associated with the Leone crime family?",
    options: [
      "Salvatore Leone",
      "Donald Love",
      "Avery Carrington",
      "Ray Machowski",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA VI character is shown alongside Lucia in the promotional material?",
    options: [
      "CJ",
      "Trevor",
      "Jason",
      "Niko",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What fictional state contains Vice City in GTA VI?",
    options: [
      "Liberty",
      "Alderney",
      "San Andreas",
      "Leonida",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which real-world region most directly inspires GTA VI's fictional Leonida?",
    options: [
      "California",
      "New York",
      "Florida",
      "Nevada",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which type of short-form social media content is prominently shown in GTA VI promotional footage?",
    options: [
      "Vertical-style videos",
      "Printed newspapers",
      "Email chains",
      "Radio transcripts",
    ],
    answerIndex: 0,
  ),

  // Beginner-friendly questions — syntax checked.
  Question(
    question: "What does GTA stand for?",
    options: [
      "Game Theft Arena",
      "Grand Tour Adventure",
      "Grand Theft Auto",
      "Great Truck Adventure",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which company develops GTA 6?",
    options: [
      "Ubisoft",
      "Valve",
      "Rockstar Games",
      "EA",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is GTA VI another name for?",
    options: [
      "Grand Theft Auto VI",
      "Game Theft VI",
      "Grand Theft Adventure",
      "Grand Tour VI",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is one of the main characters in GTA 6?",
    options: [
      "Tommy",
      "Niko",
      "CJ",
      "Lucia",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is the male protagonist shown with Lucia?",
    options: [
      "Franklin",
      "Michael",
      "Jason",
      "Trevor",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which city returns in GTA 6?",
    options: [
      "Vice City",
      "Liberty City",
      "Los Santos",
      "San Fierro",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the fictional state in GTA 6?",
    options: [
      "Alderney",
      "San Andreas",
      "Leonida",
      "Liberty",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which real-world state inspires Leonida?",
    options: [
      "Florida",
      "Nevada",
      "Texas",
      "California",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which city is Vice City inspired by?",
    options: [
      "New York",
      "Chicago",
      "Miami",
      "Los Angeles",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What does the Roman numeral VI mean?",
    options: [
      "Seven",
      "Six",
      "Five",
      "Four",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What does the Roman numeral V mean?",
    options: [
      "Six",
      "Four",
      "Three",
      "Five",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which game came before GTA VI?",
    options: [
      "GTA V",
      "GTA IV",
      "GTA San Andreas",
      "GTA III",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Which GTA game features Michael?",
    options: [
      "GTA III",
      "GTA IV",
      "Vice City",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game features CJ?",
    options: [
      "Vice City",
      "GTA V",
      "GTA IV",
      "San Andreas",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game features Niko Bellic?",
    options: [
      "GTA III",
      "GTA V",
      "Vice City",
      "GTA IV",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game features Tommy Vercetti?",
    options: [
      "GTA V",
      "Vice City",
      "GTA III",
      "GTA IV",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is Franklin in GTA V?",
    options: [
      "A protagonist",
      "A police officer",
      "A pilot",
      "A shopkeeper",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is Trevor in GTA V?",
    options: [
      "A doctor",
      "A reporter",
      "A taxi driver",
      "A protagonist",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is Michael in GTA V?",
    options: [
      "A police chief",
      "A teacher",
      "A mechanic",
      "A protagonist",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Franklin's dog called?",
    options: [
      "Max",
      "Chop",
      "Buddy",
      "Rex",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is CJ's full name?",
    options: [
      "Carl Johnson",
      "Chris Johnson",
      "Charles Jones",
      "Cal Johnson",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is Niko's last name?",
    options: [
      "Clinton",
      "Vercetti",
      "Johnson",
      "Bellic",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Tommy's last name?",
    options: [
      "Vercetti",
      "Clinton",
      "Bellic",
      "Johnson",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is Franklin's last name?",
    options: [
      "Philips",
      "Johnson",
      "Bellic",
      "Clinton",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is Michael's last name?",
    options: [
      "Clinton",
      "Johnson",
      "De Santa",
      "Bellic",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is Trevor's last name?",
    options: [
      "Clinton",
      "Johnson",
      "Philips",
      "Bellic",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What is Michael's son called?",
    options: [
      "Jimmy",
      "Lamar",
      "Ryder",
      "Roman",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is Michael's daughter called?",
    options: [
      "Tracey",
      "Amanda",
      "Denise",
      "Kate",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is Michael's wife called?",
    options: [
      "Michelle",
      "Amanda",
      "Denise",
      "Maria",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is Franklin's friend?",
    options: [
      "Lamar",
      "Jimmy",
      "Roman",
      "Ryder",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "What is the main setting of GTA V?",
    options: [
      "San Fierro",
      "Los Santos",
      "Vice City",
      "Liberty City",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What is the main setting of GTA IV?",
    options: [
      "Los Santos",
      "Las Venturas",
      "Vice City",
      "Liberty City",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the main setting of GTA Vice City?",
    options: [
      "Los Santos",
      "Liberty City",
      "San Fierro",
      "Vice City",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the main setting of GTA San Andreas?",
    options: [
      "Leonida",
      "Alderney",
      "Liberty",
      "San Andreas",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA city is inspired by Los Angeles?",
    options: [
      "Las Venturas",
      "Vice City",
      "Los Santos",
      "Liberty City",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA city is inspired by New York?",
    options: [
      "San Fierro",
      "Los Santos",
      "Liberty City",
      "Vice City",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA city is inspired by Las Vegas?",
    options: [
      "Vice City",
      "Los Santos",
      "Las Venturas",
      "Liberty City",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Which GTA city is inspired by San Francisco?",
    options: [
      "Liberty City",
      "Los Santos",
      "Vice City",
      "San Fierro",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which GTA game is set mainly in the 1980s?",
    options: [
      "GTA IV",
      "Vice City",
      "GTA V",
      "GTA III",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Which GTA game is known for GTA Online?",
    options: [
      "Vice City",
      "GTA III",
      "San Andreas",
      "GTA V",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who owns Chop in GTA V?",
    options: [
      "Lester",
      "Franklin",
      "Trevor",
      "Michael",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "What animal is Chop?",
    options: [
      "Bird",
      "Cat",
      "Dog",
      "Horse",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "What color is associated with Grove Street Families?",
    options: [
      "Blue",
      "Green",
      "Yellow",
      "Red",
    ],
    answerIndex: 1,
  ),
  Question(
    question: "Who is CJ's brother?",
    options: [
      "Ryder",
      "Roman",
      "Sweet",
      "Lamar",
    ],
    answerIndex: 2,
  ),
  Question(
    question: "Who betrayed Grove Street in GTA San Andreas?",
    options: [
      "Sweet",
      "Cesar",
      "Woozie",
      "Big Smoke",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Who is Niko Bellic's cousin?",
    options: [
      "Roman",
      "Ryder",
      "Sweet",
      "Lamar",
    ],
    answerIndex: 0,
  ),
  Question(
    question: "Who is Michael's therapist?",
    options: [
      "Dr. Norton",
      "Dr. Klebitz",
      "Dr. Haines",
      "Dr. Friedlander",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is GTA V's social network called?",
    options: [
      "ChatBook",
      "Faceworld",
      "SnapLife",
      "Lifeinvader",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "What is the in-game internet called in GTA V?",
    options: [
      "LifeNet",
      "GoWeb",
      "SnapWeb",
      "Eyefind",
    ],
    answerIndex: 3,
  ),
  Question(
    question: "Which company publishes GTA games?",
    options: [
      "Sony",
      "Nintendo",
      "Take-Two Interactive",
      "EA",
    ],
    answerIndex: 2,
  ),
];
