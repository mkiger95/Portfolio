#include <string>
#include <fstream>
#include <iostream>
#include <iomanip>

#include "reviewData.h"

using namespace std;

reviewData::reviewData()
{
	totalReviews = 0;
}

bool reviewData::readMasterReviewData(const string fname)
{
	ifstream infile;
	string line;
	string key, tmpS;
	double score;

	infile.open(fname);

	if(!infile)
		return false;

	while(!infile.eof())
	{
		getline(infile, line);

		for(int i = 0; i<10; i++)
			key += line[19+i];
		for(int i = 0; i<4; i++)
			getline(infile, line);

		tmpS = line[14];
		score = atof(tmpS.c_str());

		insert(key, score);
		totalReviews += 1;

		for(int i = 0; i<4; i++)
			getline(infile, line);

		key = "";
	}
	return true;
}

bool reviewData::getReviews(const string fname)
{
	ifstream infile;
	string key;
	bool exist;
	double score;
	unsigned int count;

  	infile.open(fname);
  	if(!infile)
  		return false;

	cout << "----------" << endl << endl;
  	cout << "Reviews List:" << endl;
  	cout << "----------" << endl;

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
  			cout << "Product, " << key << "not found." << endl;
  	}
  	return true;
}

void reviewData::showStats() const
{
	cout << "----------" << endl;
	cout << "Review Data Statistics" << endl << endl;
  cout << "Review Hash Stats:" << endl;
  showHashStats();
	cout << "Review Data Stats:" << endl;
	cout << "	Total Reviews: " << totalReviews << endl;
}

void reviewData::showMaxReview() const
{
	string key;
  	double score;
  	unsigned int count=0;

  	findMaxReview(key, score, count);
  	printProduct(key, score, count);
}

void reviewData::printAllReviews() const
{
	cout << "----------" << endl;
	cout << "Complete Hash Table" << endl;
	cout << "----------" << endl;
	printHash();
}

void reviewData::printProduct(const string tmpR, const double tmpS, const unsigned int tmpC) const
{
	double score = 0;

	score = tmpS/tmpC;

	cout << "Product:" << tmpR << endl;
  	cout << "   Avg Score: " << fixed << setprecision(2) << score << endl;
  	cout << "   Reviews: " << tmpC << endl << endl;
}

reviewData::~reviewData()
{
	totalReviews = 0;
	uniqueProducts = 0;
}
