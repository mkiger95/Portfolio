// Morgan Kiger
// Assignment 4
// Section 1002

#include <iostream>

using namespace std;

template <class myType>
struct queueNodeType
{
    myType info;
    queueNodeType<myType> * link;
};

template <class myType>
class linkedQueue
{
public:
  linkedQueue();
  bool isEmptyQueue() const;
  void enqueue(const myType& newItem);
  myType dequeue();
  void printQueue();
  ~linkedQueue();
private:
  queueNodeType<myType> * queueFront;
  queueNodeType<myType> * queueRear;
  int count;
};

template<class myType>
linkedQueue<myType>::linkedQueue()
{
  queueFront = NULL;
  queueRear = NULL;
  count = 0;
}

template<class myType>
bool linkedQueue<myType>::isEmptyQueue() const
{
  return queueFront == NULL;
}

template<class myType>
void linkedQueue<myType>::enqueue(const myType& newItem)
{
  queueNodeType<myType> * tmp;
  tmp = new queueNodeType<myType>;
  tmp -> info = newItem;
  tmp -> link = NULL;
  count++;

  if(isEmptyQueue())
    queueFront = tmp;

  else
    queueRear -> link = tmp;

  queueRear = tmp;
}

template<class myType>
myType linkedQueue<myType>::dequeue()
{
  queueNodeType<myType> * tmp;
  myType value;

  if(queueFront == NULL)
    return 0;
  else
  {
    tmp = new queueNodeType<myType>;
    tmp = queueFront;
    value = queueFront -> info;
    queueFront = queueFront -> link;
    delete tmp;
    count --;

    return value;
  }
}

template<class myType>
void linkedQueue<myType>::printQueue()
{
  queueNodeType<myType> * tmp;
  tmp = new queueNodeType<myType>;
  tmp = queueFront;

  while(tmp != NULL)
  {
    cout << tmp -> info << " ";
    tmp = tmp -> link;
  }
}

template<class myType>
linkedQueue<myType>::~linkedQueue()
{
  queueNodeType<myType> * tmp;

  while(queueFront != NULL)
  {
    tmp = queueFront;
    queueFront = queueFront -> link;
    delete tmp;
    count--;
  }
}
