#include "hashTable.h"
#include <string>

using namespace std;

class reviewData : public hashTable
{
public:
	//public functions
	reviewData();
	bool readMasterReviewData(const string);
	bool getReviews(const string);
	void showStats() const;
	void showMaxReview() const;
	void printAllReviews() const;
	void printProduct(const string, const double, const unsigned int) const;
	~reviewData();
private:
	//private variables
	unsigned int totalReviews;
};
