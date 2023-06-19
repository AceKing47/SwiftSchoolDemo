#include <iostream>
#include <string>
#include <random>

using namespace std;

string Berechne(int number) 
{
    string retVal = "";
    while (number != 1) {
        retVal += to_string(number) + " ";

        if (number % 2 == 0) {
            number /= 2;
        } else {
            number = number * 3 + 1;
        }
    }
    
    retVal += to_string(number);
    return retVal;
}

void CheckInput(string compare)
{
    while(true) 
    {
        string solution = "";
        getline(cin, solution);

        //cout << compare << endl;
        //cout << solution << endl;

        if(solution.length() > 0) 
        {
            if(solution == compare)
            {
                cout << "RICHTIG! Super!" << endl;
                break;
            } 
            else 
            {
                cout << "Leider falsch, probieren Sie es nochmal" << endl;
            }
        }
    }
}

int main() {
    
    cout << endl << "Willkommen zu meinem kleinen Rätsel" << endl;
    cout << "Versuchen Sie alle 3 Aufgaben zu lösen" << endl;
    cout << "Schwierigkeitsstufe 1: Selbst das Hirn anstrengen - in diesem Fall leicht, sonst schwer" << endl;
    cout << "Schwierigkeitsstufe 2: Das Programm dekompilieren - schwer" << endl;
    cout << "Schwierigkeitsstufe 3: Den (C++) Source Code ansehen - leicht" << endl;
    cout << "Sie können mich jederzeit um einen Tipp bitten" << endl;
    cout << "====================================================" << endl;
    cout << "Aufgabe 1: Finden Sie den Algorithmus" << endl;
    
    for(int i=1; i<9; i++)
    {
        cout << Berechne(i) << endl;
    }

    cout << "Enter zum fortfahren...";
    cin.peek();
    cout << "Aufgabe 2: Geben Sie die Reihenfolge für die Zahl 9 ein:" << endl;
    CheckInput(Berechne(9));

    cout << endl << "Aufgabe 3: Schreiben Sie ein Programm welches die Lösung für diese Zufallszahl berechnet:" << endl;
    random_device rd;
    mt19937 generator(rd());
    uniform_int_distribution<int> distribution(10, 20);
    int randomNum = distribution(generator);
    cout << "Ihre Zufallszahl: " << randomNum << endl;
    CheckInput(Berechne(randomNum));

    return 0;
}