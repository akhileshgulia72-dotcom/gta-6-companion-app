import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Charater {
  final String name;
  final String description;
  final String image;

  const Charater({
    required this.name,
    required this.description,
    required this.image,
  });
}

List<Charater> chaterlist = [
  Charater(
    name: "Lucia Caminos",
    description:
        'Lucia is a resourceful and resilient criminal seeking a better life in Vice City. Her intelligence, courage, and loyalty make her one of the central figures in the story of Grand Theft Auto VI.',
    image: 'assets/images/lucia.png',
  ),
  Charater(
    name: 'Jason Duval',
    description:
        'Calm under pressure and always ready for action, Jason navigates the dangerous criminal world of Vice City alongside Lucia, driven by ambition and loyalty.',
    image: 'assets/images/jason.png',
  ),
  Charater(name:'Cal Hampton' , 
  description:'Role: Jason friend\n Cal is a conspiracy enthusiast who spends much of his time listening to coast guard communications and browsing the internet. He is laid-back, paranoid, and prefers staying away from the spotlight. ' , 
  image: 'assets/images/Cal.png'),
  Charater(name: 'Boobie Ike ', description: 'A powerful Vice City entrepreneur who built a successful empire through real estate, nightlife, and smart business deals. Wealthy, influential, and always focused on expanding his reach, Boobie Ike is one of the city most respected businessmen.', image: 'assets/images/boobie.png')
  ,
  Charater(name: 'DreQuan Priest', description: 'A talented music producer and promoter who is making a name for himself in Vice Citys music scene. Ambitious and well-connected, DreQuan is focused on discovering new talent and turning street success into mainstream fame',
   image: 'assets/images/dre.png'),
   Charater(name: 'Bae-Luxe', description: 'One half of the rap duo Real Dimez, Bae-Luxe is a bold and confident artist known for her sharp lyrics, fearless attitude, and strong social media presence. She is determined to turn her music into lasting success in Vice City.',
    image: 'assets/images/bae.png'),
    Charater(name: 'Roxy', description: 'The other half of Real Dimez, Roxy is a charismatic rapper known for her bold personality, catchy performances, and unwavering confidence. Together with Bae-Luxe, she determined to dominate Vice City hip-hop scene and build a lasting legacy.',
     image: 'assets/images/roxy.png'),
     Charater(name: 'Raul Bautista', description: 'Raul Bautista is a charismatic, seasoned bank robber and criminal crew leader operating within Vice City.He serves as a mentor and orchestrator for protagonists Lucia and Jason, pulling them into high-stakes heists.Known for his calculating ambition, he seamlessly navigates both luxury and the criminal underworld.', image: 'assets/images/raul.png')
];

class CharaterScreen extends StatelessWidget {
  const CharaterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Charaters",
      style: GoogleFonts.aldrich(
        fontSize: 30,
        fontWeight: FontWeight.bold,

      ),
      )),
      body: ListView.builder(
        itemCount: chaterlist.length,
        itemBuilder: (context, index) {
          final charater = chaterlist[index];
          return SingleChildScrollView(
            child: Card(
               color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),),
                margin: EdgeInsets.all(20),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(20),
                      child: Image.asset(charater.image,
                      height: 250,
                      fit: BoxFit.cover,
                      width: double.infinity,),
                    ),
                    SizedBox(height: 20,),
                    Text(charater.name,
                    style: GoogleFonts.orbitron(fontSize: 25,
                    fontWeight: FontWeight.bold),),
                    SizedBox(height: 20,),
                    Text(charater.description,
                    style: GoogleFonts.aldrich(
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),)
                  ],
                ),
            
            
            ),
          );
        },
      ),
    );
  }
}
