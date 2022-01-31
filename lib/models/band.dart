class Band {
  String id;
  String name;
  int votes;

  //constructor con nombre
  //recuerda el contructor lleva el mismo nombre que la clase
  Band({this.id, this.name, this.votes});

  //factory constructor tiene como objetivo regresar
  //una nueva instancia de mi clase
  factory Band.fronMap(Map<String, dynamic> obj) => Band(
      id: obj.containsKey('id') ? obj['id'] : 'no-id',
      name: obj.containsKey('name') ? obj['name'] : 'no-name',
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes');
}
