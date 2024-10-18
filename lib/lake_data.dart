import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class LakeDataService {
  static Future<Map<String, dynamic>> fetchLakeData(String lakeCode) async {
    final url = 'https://www.swt-wc.usace.army.mil/$lakeCode.lakepage.html';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      
      // Extract data
      String currentReadings = '';
      
      // Find the "Current Readings" section
      final boxUsaceElements = document.querySelectorAll('.box-usace');
      for (var element in boxUsaceElements) {
        final titleElement = element.querySelector('.title');
        if (titleElement != null && titleElement.text.trim() == 'Current Readings') {
          final ulElement = element.querySelector('ul');
          if (ulElement != null) {
            currentReadings = ulElement.children.map((li) => li.text.trim()).join('\n');
          }
          break;
        }
      }
      
      // Construct image URL
      final imageUrl = 'https://www.swt-wc.usace.army.mil/images/x-y/$lakeCode.lakepage.jpg';

      return {
        'currentReadings': currentReadings,
        'imageUrl': imageUrl,
      };
    } else {
      throw Exception('Failed to load lake data');
    }
  }
}