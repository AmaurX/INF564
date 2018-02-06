// un exemple de fichier mini-C
// à modifier au fur et à mesure des tests
//
// la commande 'make' recompile mini-c (si nécessaire)
// et le lance sur ce fichier

struct coucou
{
  struct coucou *bidule;
};

// struct coucou
// {
//   int a;
//   // struct coucou *son;
//   // int a;
//   //float caca;
// };

int truc(int c)
{
  struct coucou s;
  // return s;
}

int main()
{
  int c;
  struct coucou *d;

  truc(1);
  //a = a + 3;
  return 1;
}
