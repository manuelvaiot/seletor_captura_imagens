# seletor_captura_imagens

Módulo para seleção/captura de uma foto e rotorno de um objeto ImagemSelecionada que retornará a string base64 e o local path da imagem. O módulo foi desenvolvido para que a seleção ou captura de uma foto seja feita sem colocar o aplicativo principal em segundo plano.

Qulquer dúvida ou ajuda na utilização do pacote fale com
[@Glauber26](https://github.com/Glauber26).

## Preparando módulo para uso

Após o módulo ser adicionado dentro do pubspec.yaml do projeto você deve seguir os seguintes passos para que ele funcione corretamente no projeto.

Não esqueça de adicionar as permissões dentro do AndroidManifest.xml
```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```
Dentro da pasta Android\app\build.gradle localize o buildTypes e adicione o trecho de codigo abaixo 
```dart
    buildTypes {
        release {
            signingConfig signingConfigs.release

            minifyEnabled true
            useProguard true

            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro' 
        }
    }
```

Ainda dentro do build.gradle, localize o defaultConfig e mude o minSdkVersion para 21.

Acesso o build.gradle a nivel do projeto, localizado dentro de android/build.gradle e adicione o código abaixo

```dart
ext {
    flutterFFmpegPackage  = "min-lts"
}
```

Após realizar os passos acima localize o seu arquivo proguard-rules.pro que deve estar dentro Android\app\
Caso o seu arquivo proguard não tenha sido criado ainda, crie-o dentro deste diretório Android\app\proguard-rules.pro e adicione o trecho de código abaixo

```dart

-keep class com.arthenica.mobileffmpeg.Config {
    native <methods>;
    void log(long, int, byte[]);
    void statistics(long, int, float, float, long , int, double, double);
}

-keep class com.arthenica.mobileffmpeg.AbiDetect {
    native <methods>;
}
```

Após seguir estes passos o módulo deve estar pronto para o uso. Compile e veja se o projeto executou sem problemas.

Um erro comum de acontecer é algo semelhante a "> GC overhead limit exceeded" ou alguma mensagem parecida. Se isso acontecer basta acessar o arquivo gradle.properties localizado no nivel de projeto dentro da pasta Android e modificar/adicionar a seguinte linha

```java
org.gradle.jvmargs=-Xmx4608m
```

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


