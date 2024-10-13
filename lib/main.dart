import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
 runApp(MyApp(futureDoctors: fetchDoctors()));
}

class MyApp extends StatelessWidget {
final Future<List<Doctor>> futureDoctors;
  const MyApp({Key? key, required this.futureDoctors}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Appointment',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Doctor Appointment'),
        ),
        body: DoctorListScreen(futureDoctors: futureDoctors),
      ),
    );
  } 
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class DoctorCard extends StatelessWidget {
  final String doctorName;
  final String specialty;  

  final int experience;

  const DoctorCard({
    Key? key,
    required this.doctorName,
    required this.specialty,
    required this.experience,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Card(
    //   child: ListTile(
    //     leading:Container(
    //       width: 60,
    //       decoration: BoxDecoration(
    //         image: DecorationImage(
    //           image: NetworkImage('https://www.shutterstock.com/image-photo/young-handsome-man-beard-wearing-260nw-1768126784.jpg'),
    //           fit: BoxFit.cover,
    //         ),
           
    //       ),
    //     ),
    //     title: Text(doctorName),
    //     subtitle: Text('$specialty, $experience+ Years'),
    //   ),
    // );

    return  Container(
     
      decoration: BoxDecoration(
    border: Border.all(
      color: const Color.fromARGB(255, 2, 176, 2),
      width: 1.5,
    ),
  ),
      child: Row(
        children: [
          Image.network('https://images.inc.com/uploaded_files/image/1920x1080/getty_481292845_77896.jpg', width: 150),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctorName,
                style: TextStyle(fontWeight: FontWeight.w600 ,  fontSize: 16 ) ),
                Text(capitalizeFirstLetter(specialty),
                style: TextStyle(fontSize: 16),),
                Text( '$experience+ Years in practice')
              ],
            ),
          )
        ],
      ),
    );
  }
}
class DoctorListScreen extends StatelessWidget {
  final Future<List<Doctor>> futureDoctors;

  const DoctorListScreen({Key? key, required this.futureDoctors}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const  Text('Nearby',
            style: TextStyle(color: Color.fromARGB(255, 106, 106, 106)),
            ),
            const  Text('Best doctors \nnearby',
             style: TextStyle(fontWeight: FontWeight.w800, fontSize: 25),
             ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: FutureBuilder<List<Doctor>>(
                  future: futureDoctors,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator()); 
                
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) 
                 {
                      final doctors = snapshot.data!;
                      return ListView.separated(
                        itemCount: doctors.length,
                        itemBuilder: (context, index) => DoctorCard(
                          doctorName: doctors[index].doctorName,
                          specialty: doctors[index].expertise,
                          experience: doctors[index].experience,
                        ),
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 30,);
                        },
                      );
                    } else {
                      return const Text('No data');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 

//Model Class for API response
class Doctor {
  final String doctorName;
  final int experience;
  final String expertise;
  final List<String> availableSlots;

  Doctor({
    required this.doctorName,
    required this.experience,
    required this.expertise,
    required this.availableSlots,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorName: json['doctorName'] as String,
      experience: json['experience'] as int,
      expertise: json['expertise'] as String,
      availableSlots:
          List<String>.from(json['availableSlots'].map((e) => e as String)),
    );
  }
}

Future<List<Doctor>> fetchDoctors() async {
  final response = await http.get(Uri.parse('https://run.mocky.io/v3/ca21f205-f2d4-4691-9f18-d02bab9cc1cb'));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as List<dynamic>;
    return jsonData.map((doctorData) => Doctor.fromJson(doctorData)).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}

  // List data = []; 
  // Future<void> fetchData() async {
  //   final response = await http.get(Uri.parse(
  //       'https://run.mocky.io/v3/ca21f205-f2d4-4691-9f18-d02bab9cc1cb'));
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       data = json.decode(response.body);
  //       for (final doctorData in data) {
  //         final doctor = Doctor.fromJson(doctorData);
  //         print(doctor);
  //       }
  //     });
  //   }
  // }


String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}
