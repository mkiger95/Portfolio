#include <string>
#include <iostream>
#include <cmath>
#include <iomanip>
#include "hashTable.h"

constexpr unsigned int hashTable::hashSizes[];

using namespace std;

//constructor to initialize variables
hashTable::hashTable()
{
	hashSize = initialHashSize;
	reSizeCount = 0;
	collisionCount = 0;
	entries = 0;
	hashReviews = new string[hashSize];
	hashScores = new double[hashSize];
	hashCounts = new unsigned int[hashSize];
}
//public insert function
bool hashTable::insert(const string tmpR, const double tmpS)
{
	double tLimit = entries/hashSize;
	int i = 1;

	if(tLimit > loadFactor)
		rehash();

	if(tmpR == "")
		return false;

	unsigned int loc = hash(tmpR);

	if(hashReviews[loc] == "")
	{
		hashReviews[loc] = tmpR;
		hashScores[loc] = tmpS;
		hashCounts[loc]++;

		entries++;
		return true;
	}

	else
	{
		while(hashReviews[loc] != "")
		{
			if(hashReviews[loc] == tmpR)
			{
				entries++;
				hashCounts[loc]++;
				hashScores[loc] += tmpS;
				return true;
			}
			loc = (loc + i*i) % hashSize;
			collisionCount++;
			i++;
		}

		hashReviews[loc] = tmpR;
		hashScores[loc] = tmpS;
		hashCounts[loc]++;

		entries++;
		return true;
	}


}
//public search function
bool hashTable::search(const string tmpR, double & tmpS, unsigned int & tmpC)
{
	unsigned int loc = hash(tmpR);
	int i = 1;

	while(hashReviews[loc] != "")
	{
		if(hashReviews[loc] == tmpR)
		{
			tmpS = hashScores[loc];
			tmpC = hashCounts[loc];
			return true;
		}
		loc = (loc + i*i) % hashSize;
		i++;
	}
	return false;
}
//public remove function
bool hashTable::remove(const string tmpR)
{
	unsigned int loc = hash(tmpR);
	int i = 1;

	while(hashReviews[loc] != "")
	{
		if(hashReviews[loc] == tmpR)
		{
			hashReviews[loc] = '*';
			hashScores[loc] = 0;
			hashCounts[loc] = 0;
			entries--;
			return true;
		}
		loc = (loc + i*i) % hashSize;
		i++;
	}
	return false;
}
//public printHash function
void hashTable::printHash() const
{
	for(unsigned int i = 0; i<hashSize; i++)
	{
		if(hashReviews[i] != "")
		{
			if(hashReviews[i] != "*")
				cout << hashReviews[i] << " : " << hashScores[i] << " : "
				<< hashCounts[i] << endl;
		}
	}
}
//public showHashStats function
void hashTable::showHashStats() const
{
	cout << "Hash Stats" << endl;
	cout << "   Current Entries Count: " << entries << endl;
  	cout << "	Current Hash Size:" << hashSize << endl;
  	cout << "   Hash Resize Operations: " << reSizeCount << endl;
  	cout << "   Hash Collisions: " << collisionCount << endl << endl;
}
//public findMaxReview function
bool hashTable::findMaxReview(string & tmpR, double & tmpS, unsigned int & tmpC) const
{
	tmpC = 0;

	if(hashReviews[0] == "")
		return false;

	for(unsigned int i = 0; i<hashSize; i++)
	{
		if(hashCounts[i] > tmpC)
		{
			tmpR = hashReviews[i];
			tmpS = hashScores[i];
			tmpC = hashCounts[i];
		}
	}
	return true;
}
//deconstructor
hashTable::~hashTable()
{
	delete [] hashReviews;
	delete [] hashScores;
	delete [] hashCounts;
}
//private insert function
bool hashTable::insert(const string tmpR, const double tmpS, const unsigned int tmpC)
{
	if(tmpR == "")
		return false;
	else
	{
		unsigned int loc = hash(tmpR);

		hashReviews[loc] = tmpR;
		hashScores[loc] = tmpS;
		hashCounts[loc] = tmpC;

		return true;
	}
	return false;
}
//private hash function
unsigned int hashTable::hash(string tmp) const
{
	unsigned int FNV_prime = 16777619;
	unsigned int FNV_offset_basis = 2166136261;

	unsigned int hash = FNV_offset_basis;
	unsigned int sLength = tmp.length();

	char cByte;
	unsigned int tmpByte;

	for(unsigned int i = 0; i<sLength; i++)
	{
		cByte = tmp[i];
		tmpByte = cByte;
		hash = hash  ^ tmpByte;
		hash = hash * FNV_prime;

	}
	if(reSizeCount == 0)
		hash = hash % initialHashSize;
	else
		hash = hash % hashSizes[reSizeCount];

	return hash;
}
//private rehash function
void hashTable::rehash()
{
	unsigned int oldSize = hashSize;
	hashSize = hashSizes[reSizeCount];

	string * oldReviews = hashReviews;
	double * oldScores = hashScores;
	unsigned int * oldCounts = hashCounts;

	hashReviews = new string[hashSize];
	hashScores = new double[hashSize];
	hashCounts = new unsigned int[hashSize];

	entries = 0;

	for(unsigned int i = 0; i<oldSize; i++)
	{
		if(oldReviews[i] != "")
			insert(oldReviews[i], oldScores[i], oldCounts[i]);
	}

	delete [] oldReviews;
	delete [] oldScores;
	delete [] oldCounts;

	reSizeCount++;
}
