//  Morgan Kiger
//  Assignment 5
//  Section 1002

#include "avlTree.h"
#include <string>

using namespace std;

class reviewData : public avlTree<string>
{
public:
  reviewData();
  bool readMasterReviewData(const string);
  bool getReviews(const string);
  void showStats() const;
  void showMaxReview() const;
  void printAllReviews() const;
  void printProduct(const string, const double, const unsigned int);
  ~reviewData();
private:
  int totalReviews;
};
