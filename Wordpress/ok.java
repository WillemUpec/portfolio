class Rectangle {
  constructor(largeur,hauteur) {
    this.largeur = largeur
    this.hauteur = hauteur
  }
  calculersurface() { 
    console.log(this.largeur * this.hauteur)
  }
calculerperimetre() {
  console.log(2*(this.largeur + this.hauteur))}
}

const Rectangle1 = new Rectangle(10,5)


Rectangle1.calculersurface()
Rectangle1.calculerperimetre()