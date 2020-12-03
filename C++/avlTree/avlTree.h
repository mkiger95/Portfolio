//  Morgan Kiger
//  Assignment 5
//  Section 1002

#include <iostream>
#include <iomanip>
#include <algorithm>

using namespace std;

template <class myType>
struct nodeType
{
  myType  keyValue;
  double  score;
  unsigned int  count;
  nodeType<myType> * left;
  nodeType<myType> * right;
};

template <class myType>
class avlTree
{
public:
  avlTree();
  void destroyTree();
  int countNodes() const;
  int height() const;
  bool search(myType, double&, unsigned int&) const;
  void printTree() const;
  void insert(myType, double);
  bool findMaxReview(string&, double&, unsigned int&) const;
  ~avlTree();
private:
  void destroyTree(nodeType<myType> *);
  int countNodes(nodeType<myType> *) const;
  int height(nodeType<myType> *) const;
  nodeType<myType> * search(myType, nodeType<myType> *) const;
  void printTree(nodeType<myType> *) const;
  nodeType<myType> * insert(myType, double, nodeType<myType> *);
  void findMaxReview(nodeType<myType> *, string&, double&, unsigned int&) const;
  nodeType<myType> * rightRotate(nodeType<myType> *);
  nodeType<myType> * leftRotate(nodeType<myType> *);
  int getBalance(nodeType<myType> *) const;
//--------------------------------------------------------------------------
  nodeType<myType> * root;
};
// public avlTree()
// initializes varibales
template <class myType>
avlTree<myType>::avlTree()
{
  root = NULL;
}
// public destroyTree()
// destroys tree recursively
template <class myType>
void avlTree<myType>::destroyTree()
{
  destroyTree(root);
  root = NULL;
}
// public countNodes()
// counts the total number of nodes in the tree found recursively
template <class myType>
int avlTree<myType>::countNodes() const
{
  return countNodes(root);
}
// public height()
// returns the height of the tree found recursively
template <class myType>
int avlTree<myType>::height() const
{
  return height(root);
}
// public search()
// searches through the tree for the passed keyValue and
// returns true if found, false if not
template <class myType>
bool avlTree<myType>::search(myType tmpK, double& tmpS, unsigned int& tmpC) const
{
  nodeType<myType> * tmp = search(tmpK, root);

  if(tmp == NULL)
    return false;
  else
  {
    tmpS = tmp -> score;
    tmpC = tmp -> count;
    return true;
  }
}
// public printTree()
// prints the tree out in post order
template <class myType>
void avlTree<myType>::printTree() const
{
  printTree(root);
}
// public insert()
// attempts to insert node by calling private insert
template <class myType>
void avlTree<myType>::insert(myType tmpK, double tmpS)
{
  insert(tmpK, tmpS, root);
}
// public findMaxReview()
// finds the max number of reviews and returns true with
// values stored in address of varibales passed
template <class myType>
bool avlTree<myType>::findMaxReview(string& tmpK, double& tmpS, unsigned int& tmpC) const
{
  findMaxReview(root, tmpK, tmpS, tmpC);
  if(root == NULL)
    return false;
  else
    return true;
}
// private destroyTree()
// recursively destroys tree
template <class myType>
void avlTree<myType>::destroyTree(nodeType<myType> * tmp)
{
  if(tmp == NULL)
    return;

  destroyTree(tmp -> left);
  destroyTree(tmp -> right);
  delete tmp;
}
// private countNodes()
// recursively counts every node in the tree
template <class myType>
int avlTree<myType>::countNodes(nodeType<myType> * tmp) const
{
  if(tmp == NULL)
    return 0;
  return 1 + countNodes(tmp -> left) + countNodes(tmp -> right);
}
// private height()
// recursively finds the height of the tree
template <class myType>
int avlTree<myType>::height(nodeType<myType> * tmp) const
{
  if(tmp == NULL)
    return 0;
  else
    return max(height(tmp -> left), height(tmp -> right)) + 1;
}
// private search()
// if finds the keyValue returns the pointer
template <class myType>
nodeType<myType> * avlTree<myType>::search(myType tmpKey, nodeType<myType> * tmp) const
{
  if(tmp -> keyValue == tmpKey)
    return tmp;
  if(tmpKey > tmp -> keyValue)
    return search(tmpKey, tmp -> right);
  if(tmpKey < tmp -> keyValue)
    return search(tmpKey, tmp -> left);
  else
    return NULL;
}
// private printTree()
// recursively prints tree in post order
template <class myType>
void avlTree<myType>::printTree(nodeType<myType> * tmp) const
{
  if(tmp != NULL)
  {
    printTree(tmp -> left);
    printTree(tmp -> right);
    cout << tmp -> keyValue << "  " << fixed << setprecision(2) << tmp -> score << "  "
    << setprecision(0) << tmp -> count << endl;
  }
  return;
}
// private insert()
// inserts node if current pointer is NULL, goes left or right if needs to
template <class myType>
nodeType<myType> * avlTree<myType>::insert(myType tmpK, double tmpS, nodeType<myType> * tmp)
{
  if(tmp == NULL)
  {
    nodeType<myType> * node = new nodeType<myType>;
    node -> keyValue = tmpK;
    node -> left = NULL;
    node -> right = NULL;
    node -> score = tmpS;
    node -> count = 1;
    if(root == NULL)
    {
      root = node;
      return root;
    }
    return node;
  }
  else if(tmpK == tmp -> keyValue)
  {
    tmp -> score += tmpS;
    tmp -> count += 1;
  }
  else if(tmpK < tmp -> keyValue)
    tmp -> left = insert(tmpK, tmpS, tmp -> left);
  else
    tmp -> right = insert(tmpK,tmpS, tmp -> right);

  int bfactor = getBalance(tmp);

  //case 1
  if(bfactor > 1 && tmpK < tmp -> left -> keyValue)
    return rightRotate(tmp);
  //case 2
  if(bfactor < -1 && tmpK > tmp -> right -> keyValue)
    return leftRotate(tmp);

  //case 3
  if(bfactor > 1 && tmpK > tmp -> left -> keyValue)
  {
    tmp -> left = leftRotate(tmp -> left);
    return rightRotate(tmp);
  }
  //case 4
  if(bfactor < -1 && tmpK < tmp -> right -> keyValue)
  {
    tmp -> right = rightRotate(tmp -> right);
    return leftRotate(tmp);
  }
  return tmp;
}
// private findMaxReview()
// recursively finds the highest count
template <class myType>
void avlTree<myType>::findMaxReview(nodeType<myType> * tmp, string& tmpK, double& tmpS, unsigned int& tmpC) const
{
  if(tmp == NULL)
    return;
  findMaxReview(tmp -> left, tmpK, tmpS, tmpC);
  findMaxReview(tmp -> right, tmpK, tmpS, tmpC);
  if(tmpC < tmp -> count)
  {
    tmpK = tmp -> keyValue;
    tmpS = tmp -> score;
    tmpC = tmp -> count;
  }
}
// private rightRotate()
// rotates tree to the right at the given point passed
template <class myType>
nodeType<myType> * avlTree<myType>::rightRotate(nodeType<myType> * y)
{
  nodeType<myType> * x = y -> left;
  y -> left = x -> right;
  x -> right = y;
  if(x -> right -> keyValue == root -> keyValue)
    root = x;
  return x;
}
// private leftRotate()
// rotates tree to the left at the given point passed
template <class myType>
nodeType<myType> * avlTree<myType>::leftRotate(nodeType<myType> * x)
{
  nodeType<myType> * y = x -> right;
  x -> right = y -> left;
  y -> left = x;
  if(y -> left -> keyValue == root -> keyValue)
    root = y;
  return y;
}
// private getBalance()
// gets the balancefactor to check if unbalanced
template <class myType>
int avlTree<myType>::getBalance(nodeType<myType> * tmp) const
{
  return height(tmp -> left) - height(tmp -> right);
}
// public ~avlTree()
// deallocates the tree
template <class myType>
avlTree<myType>::~avlTree()
{
  destroyTree(root);
}
