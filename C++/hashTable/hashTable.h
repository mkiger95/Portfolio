#include <string>
#include <iostream>

using namespace std;

class hashTable
{
public:
	//public functions
	hashTable();
	bool insert(const string, const double);
	bool search(const string, double &, unsigned int &);
	bool remove(const string);
	void printHash() const;
	void showHashStats() const;
	bool findMaxReview(string &, double &, unsigned int &) const;
	~hashTable();
private:
	//private varibales
	unsigned int hashSize;
	unsigned int reSizeCount;
	unsigned int collisionCount;
	unsigned int entries;
	//private pointers
	string * hashReviews;
	double * hashScores;
	unsigned int * hashCounts;
	//private functions
	bool insert(const string, const double, const unsigned int);
	unsigned int hash(string) const;
	void rehash();
	//private const variables
	static constexpr double loadFactor = 0.65;
	static constexpr unsigned int initialHashSize = 1013;
	static constexpr unsigned int hashSizes[12] = {30011, 60013, 120017, 240089,
												   480043, 960017,1920013, 3840037,
												   7680103, 15360161, 30720299, 61440629};
};
