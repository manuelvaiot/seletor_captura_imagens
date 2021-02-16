# seletor_captura_imagens

Módulo para seleção/captura de uma foto e rotorno de um objeto ImagemSelecionada que retornará a string base64 e o local path da imagem. O módulo foi desenvolvido para que a seleção ou captura de uma foto seja feita sem colocar o aplicativo principal em segundo plano.

## Getting Started

Qulquer dúvida ou ajuda na utilização do pacote fale com
[@Glauber26](https://github.com/Glauber26).


## Como usar
A utilização do módulo é bem simples, para acessar a classe da câmera ou da galeria de fotos do dspositivo basta instanciar um objeto da classe ImagemSelecionada e chamar a rota Galeria ou Camera com o navigator colocando um await no objeto instanciado

```dart
ImagemSelecionada imagemSelecionada = await Navigator.push(
    context,
    MaterialPageRoute( builder: (context) => Galeria())
);

ImagemSelecionada imagemSelecionada = await Navigator.push(
    context,
    MaterialPageRoute( builder: (context) => Camera())
);
```
Tanto a classe galeria quanto a classe Câmera tem parametros opcionais colorPrimaria e colorSecundaria que podem ser passados caso voce tenha as cores padrão do seu aplicativo, caso esses parametros não forem passados cores padrões serão aplicadas nas interfaces de captura/seleção de imagem.

Caso o objeto imagemSelecionada retorne nullo, significa que alguma permissão solicitada não foi concedida, caso contrário o Navigator retornará um objeto imagemSelecionada válido para uso.

Um exemplo completo de como utilizar este módulo se encontra na main.
