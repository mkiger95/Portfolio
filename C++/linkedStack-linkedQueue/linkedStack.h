// Morgan Kiger
// Assignment 4
// Section 1002

using namespace std;

template <class myType>
struct nodeType
{
    myType item;
    nodeType<myType> * link;
};

template <class myType>
class linkedStack
{
public:
  linkedStack();
  bool isEmpty() const;
  void push(const myType& newItem);
  myType pop();
  ~linkedStack();
private:
  nodeType<myType> * stackTop;
  int itemCount;
};

template<class myType>
linkedStack<myType>::linkedStack()
{
  stackTop = NULL;
  itemCount = 0;
}

template<class myType>
bool linkedStack<myType>::isEmpty() const
{
  return stackTop == NULL;
}

template<class myType>
void linkedStack<myType>::push(const myType &newItem)
{
  nodeType<myType> * tmp;

  tmp = new nodeType<myType>;
  tmp -> item = newItem;
  tmp -> link = stackTop;
  stackTop = tmp;
  itemCount++;
}

template<class myType>
myType linkedStack<myType>::pop()
{
  nodeType<myType> * tmp;
  myType value;

  if(stackTop == NULL)
    return 0;
  else
  {
    tmp = new nodeType<myType>;
    tmp = stackTop;
    value = tmp -> item;
    stackTop = stackTop -> link;
    delete tmp;
    itemCount--;

    return value;
  }
}

template<class myType>
linkedStack<myType>::~linkedStack()
{
  nodeType<myType> * tmp;

  while(stackTop != NULL)
  {
    tmp = stackTop;
    stackTop = stackTop -> link;
    delete tmp;
    itemCount --;
  }
}
