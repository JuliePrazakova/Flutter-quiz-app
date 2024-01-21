# Device-Agnostic Design Course Project I

## Quiz app
### Description
This quiz application offers an engaging user experience, presenting questions on diverse topics. Users can submit answers, receive real-time feedback, and track their progress with the app seamlessly integrating SharedPreferences for persistent user data. Enjoy an interactive learning experience with the ability to seamlessly navigate through questions and view comprehensive statistics on correct answers.

### 3 challenges during the development
1. Shared preferences
The biggest challenge I had to face was creating the Statistics screen - particularly the functionality of Total correct answers number implemented via SharedReferences. 

2. Logic of changing the question
Another problem to solve was to create the logic behid all the proccesses while changing the question and updating several variables to get the needed behaviour. From error and success handlers to actually changing the question.

3. Mocking the API calls
I did have some experience even before but mostly with E2E testing, thus writing unit tests was quit challenging for me. Mainly to understand the princip of mocking API and applying it suitable for my code.
### 3 key learning moments from working on the project
1. Finally understanding the SharedReferences correctly. During the course I wasn't fully aware of what is actually going on, but since having a bigger project and more space to fully see all the connections I understood the topic very well.

2. Orientation in the code. My orientation was very chaotic at the beginning but during this project I found the patterns I know from React and that helped me a lot, to realize it's not that different.

3. Learning how to work with external API efectivelly and how to mock its calls in unit tests. Next time I will be more careful on how I build the project architecture form the beginning so it would be easily tested. 

### List of dependencies and their versions
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  shared_preferences: ^2.0.8
  riverpod: ^2.3.2
  flutter_riverpod: ^2.4.9
  go_router: ^13.0.1
  http: ^1.2.0

dev_dependencies:
  mockito: ^5.4.4
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  nock: ^1.2.1
  build_runner: ^2.4.8
