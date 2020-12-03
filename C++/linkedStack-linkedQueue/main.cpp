// Morgan Kiger Section 1002 Assignment #4

/*
    The expected input is a string to be tested to see if it is a palinodrome
    or not. If less than 2 arguments are provided, usage message will display.
    If more than 2 arguments are provided, error will display. If 2 arguments
    are provided then good. Output will state if given string is a palinodrome
    or not.
 */
 
#include <cctype>
#include <iostream>
#include <string>
#include <cstdlib>
#include <sstream>

using namespace std;

#include "linkedQueue.h"
#include "linkedStack.h"

int main(int argc, char * argv[])
{
// ------------------------------
// Command argument check

  string stars;
  stars.append(60, '*');

  string input;
  int slen;

  if(argc == 1)
  {
    cout << "Usage: ./main '(insert string here)'" << endl;
    exit (1);
  }

  if(argc > 2)
  {
    cout << "Too many arguments entered. Expected = 2" << endl;
    exit (1);
  }

  if(argc == 2)
  {
    input = argv[1];
  }

  slen = input.length();

// ------------------------------
//  Command line args ok, display initial headers.

	cout << stars << endl;
  cout << "Morgan Kiger - Sec 1002" << endl;
	cout << "CS 302 - Assignment #4" << endl;
	cout << "Palindrome Checker." << endl;
  cout << stars << endl;
	cout << endl;

// ------------------------------
// Stack implementation
  linkedStack<char> sStack;
  bool pStack = false;
// Fill up the Stack with input
  for(int i = 0; i < slen; i++)
  {
    if(isalpha(input[i]) || isdigit(input[i]))
    {
      input[i] = tolower(input[i]);
      sStack.push(input[i]);
    }
  }
// check the input with the stack to see if palindrome
  char check;

  for(int i = 0; i < slen; i++)
  {
    if(input[i] == ' ' || ispunct(input[i]))
      continue;

    check = sStack.pop();

    if(isalpha(check) || isdigit(check))
    {
      check = tolower(check);

      if(check == input[i])
        pStack = true;
      else
      {
        pStack = false;
        break;
      }
    }
  }

  // ------------------------------
  // Queue implementation
  linkedQueue<char> sQueue;
  bool pQueue = false;
// Fill up the Queue with input
  for(int i = 0; i < slen; i++)
  {
    if(isalpha(input[i]) || isdigit(input[i]))
    {
      input[i] = tolower(input[i]);
      sQueue.enqueue(input[i]);
    }
  }
// check the input with the queue to see if palindrome
  for(int i = 0; i < slen; i++)
  {
    if(input[i] == ' ' || ispunct(input[i]))
      continue;

    check = sQueue.dequeue();

    if(isalpha(check) || isdigit(check))
    {
      check = tolower(check);

      if(check == input[i])
        pQueue = true;
      else
      {
        pQueue = false;
        break;
      }
    }
  }

// if test for both stack and queue pass return results
  if(pStack == true && pQueue == true)
  {
    cout << "The string: '" << input << "' is a palindrome." << endl;
  }
  else
      cout << "The string: '" << input << "' is not a palindrome." << endl;

  return 0;
}
