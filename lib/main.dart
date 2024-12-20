import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'lake_data.dart';
import 'login_page.dart';
import 'user_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lake App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  final String uid;
  SplashScreen({required this.uid});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance.ref().child('users').child(widget.uid).once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _firstName = userData['firstName'] ?? '';
          _lastName = userData['lastName'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[300]!, Colors.blue[700]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/usace_logo.png',
                width: 100,
                height: 100,
              ),
              SizedBox(height: 20),
              Text(
                'Hello $_firstName $_lastName, welocme to USACE Lake Water Level App',
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                child: Text('Get Started'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LakeSelectionPage(uid: widget.uid)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class LakeSelectionPage extends StatefulWidget {
  final String uid;
  LakeSelectionPage({required this.uid});

  @override
  _LakeSelectionPageState createState() => _LakeSelectionPageState();
}

class _LakeSelectionPageState extends State<LakeSelectionPage> {
  final Map<String, String> lakes = {
    'Arcadia Lake, OK': 'ARCA',
    'Big Hill Lake, KS': 'BIGH',
    'Birch Lake, OK': 'BIRC',
    'Broken Bow Lake, OK': 'BROK',
    'Canton Lake, OK': 'CANT',
    'Chouteau Lock and Dam, OK': 'CHOU',
    'Copan Lake, OK': 'COPA',
    'Council Grove Lake, KS': 'COUN',
    'El Dorado Lake, KS': 'ELDR',
    'Elk City Lake, KS': 'ELKC',
    'Eufaula Lake, OK': 'EUFA',
    'Fall River Lake, KS': 'FALL',
    'Fort Gibson Lake, OK': 'FGIB',
    'Fort Supply Lake, OK': 'FTSU',
    'Great Salt Plains Lake, OK': 'GSAL',
    'Heyburn Lake, OK': 'HEYB',
    'Hugo Lake, OK': 'HUGO',
    'Hulah Lake, OK': 'HULA',
    'John Redmond Reservoir, KS': 'JOHN',
    'Kaw Lake, OK': 'KAWL',
    'Keystone Lake, OK': 'KEYS',
    'Lake Texoma, OK/TX': 'TEXO',
    'Marion Reservoir, KS': 'MARI',
    'Newt Graham Lock and Dam, OK': 'NEWT',
    'Oologah Lake, OK': 'OOLO',
    'Optima Lake, OK': 'OPTI',
    'Pat Mayse Lake, TX': 'PATM',
    'Pine Creek Lake, OK': 'PINE',
    'Robert S. Kerr Lock and Dam, OK': 'ROBE',
    'Sardis Lake, OK': 'SARD',
    'Skiatook Lake, OK': 'SKIA',
    'Tenkiller Lake, OK': 'TENK',
    'Toronto Lake, KS': 'TORO',
    'Truscott Lake, TX': 'TRUS',
    'Waurika Lake, OK': 'WAUR',
    'W.D. Mayo Lock and Dam, OK': 'MAYO',
    'Webbers Falls Lock and Dam, OK': 'WEBB',
    'Wister Lake, OK': 'WIST',
  };

  String? selectedLake;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select a Lake')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: selectedLake,
              hint: Text('Please select a lake'),
              items: lakes.keys.map((String lake) {
                return DropdownMenuItem<String>(
                  value: lake,
                  child: Text(lake),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedLake = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('View Lake Data'),
              onPressed: selectedLake != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainAppPage(
                            selectedLake: selectedLake!,
                            lakeCode: lakes[selectedLake]!,
                            uid: widget.uid,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
class MainAppPage extends StatefulWidget {
  final String selectedLake;
  final String lakeCode;
  final String uid;
  MainAppPage({required this.selectedLake, required this.lakeCode, required this.uid});

  @override
  _MainAppPageState createState() => _MainAppPageState();
}

class _MainAppPageState extends State<MainAppPage> {
  int _selectedIndex = 0;
  Map<String, dynamic> _lakeData = {};
  String _firstName = '';
  String _lastName = '';

  @override
  void initState() {
    super.initState();
    _fetchLakeData();
    _fetchUserData();
  }

  Future<void> _fetchLakeData() async {
    try {
      final data = await LakeDataService.fetchLakeData(widget.lakeCode);
      setState(() {
        _lakeData = data;
      });
    } catch (e) {
      print('Error fetching lake data: $e');
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DatabaseEvent event = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(widget.uid)
          .once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> userData = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _firstName = userData['firstName'] ?? '';
          _lastName = userData['lastName'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  List<Widget> _widgetOptions() {
    return <Widget>[
      LakeInfoPage(lakeData: _lakeData, lakeName: widget.selectedLake),
      Text('Search Page'),
      UserProfilePage(uid: widget.uid, firstName: _firstName, lastName: _lastName),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lake App - ${widget.selectedLake}'),
      ),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class LakeInfoPage extends StatelessWidget {
  final Map<String, dynamic> lakeData;
  final String lakeName;

  LakeInfoPage({required this.lakeData, required this.lakeName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lakeData['imageUrl'] != null)
            Image.network(
              lakeData['imageUrl'],
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
                  Text('Error loading image'),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lakeName, style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: 16),
                Text('Current Readings:', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Text(lakeData['currentReadings'] ?? 'Loading...'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}