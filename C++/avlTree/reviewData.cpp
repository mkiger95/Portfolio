
#include <fstream>
#include <iostream>
#include <iomanip>
#include <stdlib.h>
#include "reviewData.h"

//initializes the varibales
reviewData::reviewData()
{
  totalReviews = 0;
}
//grabs input file and reads from file, inserts data into the tree
//keeps track of total inserts
//returns true if file was read correctly, else false
bool reviewData::readMasterReviewData(const string tmp)
{
  ifstream infile;
  string line;
  string key, tmpS;
  double score;

  infile.open(tmp);
  if(!infile)
    return false;
  while(!infile.eof())
  {
    getline(infile, line);
    for(int i=0; i<10; i++)
      key += line[19+i];
    for(int i=0; i<4; i++)
      getline(infile, line);
    tmpS = line[14];
    score = atof(tmpS.c_str());
    insert(key, score);
    totalReviews += 1;
    for(int i=0; i<4; i++)
      getline(infile, line);
    key = "";
  }
  return true;
}
//reads file and checks if given keyValue is within tree
//returns true if found, else false
bool reviewData::getReviews(const string tmp)
{
  ifstream infile;
  string key;
  bool exist;
  double score;
  unsigned int count;

  cout << "----------" << endl << endl;
  cout << "Reviews List:" << endl;
  cout << "----------" << endl;

  infile.open(tmp);
  if(!infile)
    return false;
  while(!infile.eof())
  {
    getline(infile, key);
    if(key == "")
      continue;
    cout << "prod: " << key << endl;
    exist = search(key, score, count);
    if(exist == true)
      printProduct(key, score, count);
    else
      cout << "Product, " << key << " not found." << endl;
  }
  return true;
}
//prints out the total Statistics for the tree
void reviewData::showStats() const
{
  int h = height();
  int unique = countNodes();
  cout << "----------" << endl;
  cout << "Review Data Statistics:" << endl << endl;
  cout << "Review Data Tree Stats:" << endl;
  cout << "   Tree Height: " << h << endl << endl;
  cout << "Review Data Stats:" << endl;
  cout << "   Total Reviews: " << totalReviews << endl;
  cout << "   Unique Products: " << unique << endl;
}
//shows the product with the most Reviews
void reviewData::showMaxReview() const
{
  string key;
  double score;
  unsigned int count=0;

  findMaxReview(key, score, count);

  score = score/count;

  cout << "----------" << endl;
  cout << "Product: " << key << endl;
  cout << "   Avg Score: " << fixed << setprecision(2) << score << endl;
  cout << "   Reviews: " << count << endl;
}
//prints out the whole tree
void reviewData::printAllReviews() const
{
  cout << "----------" << endl;
  cout << "Complete Tree: " << endl;
  printTree();
}
//prints out a specific product of the tree
void reviewData::printProduct(const string tmpK, const double tmpS, const unsigned int tmpC)
{
  double score = 0;

  score = tmpS/tmpC;
  cout << "Product:" << tmpK << endl;
  cout << "   Avg Score: " << fixed << setprecision(2) << score << endl;
  cout << "   Reviews: " << tmpC << endl << endl;
}
//deallocates the memory
reviewData::~reviewData()
{
  totalReviews = 0;
}
