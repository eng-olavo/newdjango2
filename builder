(AULA-36)
-- Criação do projeto
-- Instalação das bibliotecas
-- Criação do project e app
-- Configuração do arquivo settings.py
-- Criação da base de dados no mysql workbench

ARQUIVO: settings.py

ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'core',
    'bootstrap4',
    'stdimage',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    #'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',


TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': ['templates'],


DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'newdjango2',
        'USER': 'root',
        'PASSWORD': 'root',
        'HOST': 'localhost',
        'PORT': '3306'
    }
}

*** No mysql workbench: CREATE DATABASE newdjango2;

LANGUAGE_CODE = 'pt-br'

TIME_ZONE = 'America/Sao_Paulo'

STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')


(AULA-37)
-- Criação das views
-- Criação do diretório templates e dos arquivos html
-- Criação do diretório static e seus subdiretórios: css, js, images

ARQUIVO: core/views.py

from django.shortcuts import render


def index(request):
    return render(request, 'index.html')

def contato(request):
    return render(request, 'contato.html')

def produto(request):
    return render(request, 'produto.html')


DIRETÓRIO: templates
Criação do diretório templates, no app core
Criação dos arquivos HTML no diretório templates: index.html, contato.html e produto.html


DIRETÓRIO: static
Criação do diretório static, no app core
Criação dos subdiretórios: css, images e js



(AULA-38)
-- Criação das rotas
-- Criação das migrations
-- Criação do superuser

Arquivo: django/urls.py:

import include:
from django.urls import path, include

Redireciona as rotas para o novo arquivo core/urls.py:

urlpatterns = [
    path('admin/', admin.site.urls),
    path('',include('core.urls')),
]


Criar o arquivo core/urls.py

from django.urls import path
from .views import index, contato, produto

urlpatterns = [
    path('', index, name='index'),
    path('contato/', contato, name='contato'),
    path('produto/', produto, name='produto'),
]


* instalar a biblioteca MySQL:
pip install MySQL

* executar o comando "migrate":
python manage.py migrate

* criar o superuser:
python manage.py createsuperuser

* rodar a aplicação no servidor python
python manage.py runserver




(AULA-39)
-- Criação do arquivo de formulários: forms.py

em core, criar o arquivo: forms.py

from django import forms


class ContatoForm(forms.Form):
    nome = forms.CharField(label='Nome', max_length=128)
    email = forms.EmailField(label='E-Mail', max_length=128)
    assunto = forms.CharField(label='Assunto', max_length=128)
    mensagem = forms.CharField(label='Mensagem', widget=forms.Textarea())



*** TESTAR os opções da class forms !!!
dir(forms)


refatorar o arquivo: core/views.py,
importar o ContatoForm,
criar a instância da classe na view contato,
criar a variável context

from .forms import ContatoForm

def contato(request):
    form = ContatoForm()    # Cria uma instânica da classe ContatoForm

    context = {
        'form' : form
    }

    return render(request, 'contato.html', context)



Editar os arquivos html para inserir a biblioteca bootstrap e chamada dos arquivos static:

{% load bootstrap4 %}
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Contato</title>
    {% bootstrap_css %}
</head>
<body>
  <h3>Contato</h3>

{% bootstrap_javascript jquery='full' %}
</body>
</html>

Criar o <form> no html, com action=post e o {% csrf_token %}

... arquivo contato.html completamente refatorado com os recursos da bliblioteca bootstrap:

{% load bootstrap4 %}
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Contato</title>
    {% bootstrap_css %}
</head>
<body>
    <div class="container">
        <h1>Contato</h1>
        {% bootstrap_messages %}

        <form action="{% url 'contato' %}" method="post" class="form" autocomplete="off">
            {% csrf_token %}
            {% bootstrap_form form %}

            {% buttons %}
                <button type="submit" class="btn btn-primary">Enviar Mensagem</button>
            {% endbuttons %}

        </form>
    </div>


{% bootstrap_javascript jquery='full' %}
</body>
</html>


... arquivo views.py refatorado .... alterações na def contato(), importação do django.contrib messages:

from django.contrib import messages

def contato(request):
    form = ContatoForm(request.POST or None)    # Cria uma instânica da classe ContatoForm
    if str(request.method) == 'POST':
        if form.is_valid():
            nome = form.cleaned_data['nome']
            email = form.cleaned_data['email']
            assunto = form.cleaned_data['assunto']
            mensagem = form.cleaned_data['mensagem']

            print('mensagem enviada!')
            print(f'Nome: {nome}')
            print(f'E-mail: {email}')
            print(f'Assunto: {assunto}')
            print(f'Mensagem: {mensagem}')

            messages.success(request, 'E-Mail enviado com sucesso...')
            form = ContatoForm()
        else:
            messages.error(request, ' Erro ao enviar o E-Mail...')

    context = {
        'form' : form
    }

    return render(request, 'contato.html', context)


(AULA-40)
-- Envio de e-mails

settings:

# Configurações de e-mail
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

"""
EMAIL_HOST = 'localhost'
EMAIL_HOST_USER = 'no-reply@seudominio.com.br'
EMAIL_PORT = 587
EMAIL_USER_TSL = 'True'
EMAIL_HOST_PASSWORD = 'senha'
"""

Criar método na classe ContatoForms(), no arquivo forms.py:

    def send_mail(self):
        nome = self.cleaned_data['nome']
        email = self.cleaned_data['email']
        assunto = self.cleaned_data['assunto']
        mensagem = self.cleaned_data['mensagem']

        conteudo = f'Nome: {nome}\nE-Mail: {email}\nAssunto: {assunto}\nMensagem:{mensagem}'

        mail = EmailMessage(
            subject='E-Mail enviado com sucesso!',
            body=conteudo,
            from_email= 'contato@seudominio.com.br',
            to=['contato@seudominio.com.br', 'outro@dom.com.br'],
            headers={'Reply-to:email'}
        )
        mail.send()

Altera a função contato(), no arquivo views.py:

        if form.is_valid():
            # nome = form.cleaned_data['nome']
            # email = form.cleaned_data['email']
            # assunto = form.cleaned_data['assunto']
            # mensagem = form.cleaned_data['mensagem']
            #
            # print('mensagem enviada!')
            # print(f'Nome: {nome}')
            # print(f'E-mail: {email}')
            # print(f'Assunto: {assunto}')
            # print(f'Mensagem: {mensagem}')
            form.send_mail()
            messages.success(request, 'E-Mail enviado com sucesso...')
            form = ContatoForm()


(AULA-41)
Configurando o models....

arquivo models.py:

from django.db import models
from stdimage.models import StdImageField

# SIGNALS
from django.db.models import signals
from django.template.defaultfilters import slugify


# Classe abstata.... não será criada uma tabela no BD para esta classe.
class Base(models.Model):
    criado = models.DateField('Data de criação', auto_now_add=True)
    modificado = models.DateField('Data de atualização', auto_now=True)
    ativo = models.BooleanField('Ativo?', default=True)

    class Meta:
        abstract = True

class Produto(Base):
    nome = models.CharField('Nome', max_length=128)
    preco = models.DecimalField('Preco', max_digits=8, decimal_places=2)
    estoque = models.IntegerField('Estoque')
    imagem = StdImageField('Imagem', upload_to='produtos', variations={'thumb': (124,124)})
    slug = models.SlugField('Slug', max_length=128, blank=True, editable=False)

    def __str__(self):
        return self.nome


def produto_pre_save(signal, instance, sender, **kwargs):
    instance.slug = slugify(instance.nome)

signals.pre_save.connect(produto_pre_save(), sender=Produto)


* makemigrations
python manage.py makemigrations
python manage.py migrate



Arquivo admin.py:

from django.contrib import admin
from .models import Produto


@admin.register(Produto)
class ProdutoAdmin(admin.ModelAdmin):
    list_display = ('nome','preco','estoque','slug', 'criado', 'modificado', 'ativo')

executar e criar novos produtos.....



(AULA-42)

forms.py:

from .models import Produto

class ProdutoModelForm(forms.ModelForm):

    class Meta:
        model = Produto
        fields = ['nome', 'preco', 'estoque', 'imagem']

def produto(request):
    return render(request, 'produto.html')


views.py:

from .forms import ContatoForm, ProdutoModelForm

def produto(request):
    if str(request.method) == 'POST':
        form = ProdutoModelForm(request.POST, request.FILES)
        if form.is_valid():
            prod = form.save(commit=False)

            print(f'Nome: {prod.nome}')
            print(f'Preço: {prod.preco}')
            print(f'Estoque: {prod.estoque}')
            print(f'Imagem: {prod.imagem}')

            messages.success(request, 'Produto salvo com sucesso!')
        else:
            messages.error(request,'Erro ao salvar o produto.')
    else:
        form = ProdutoModelForm()
    context = {
        'form': form
    }
    return render(request, 'produto.html',context)


editar o produto.html:

{% load bootstrap4 %}
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Produto</title>
    {% bootstrap_css %}
</head>
<body>
    <div class="container">
        <h1>Produto</h1>
        {% bootstrap_messages %}

        <form action="{% url 'produto' %}" method="post" class="form" autocomplete="off" enctype="multipart/form-data">
            {% csrf_token %}
            {% bootstrap_form form %}

            {% buttons %}
                <button type="submit" class="btn btn-primary">Cadastrar</button>
            {% endbuttons %}

        </form>
    </div>

{% bootstrap_javascript jquery='full' %}
</body>
</html>


(Aula-43)
salvando dados no bd, com imagens....

settings.py:

MEDIA_URL = 'media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

urls.py:

from django.conf.urls.static import static
from django.conf import settings

urlpatterns = [
    path('admin/', admin.site.urls),
    path('',include('core.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)


views.py:

def produto(request):
    if str(request.method) == 'POST':
        form = ProdutoModelForm(request.POST, request.FILES)
        if form.is_valid():
            form.save()

            #prod = form.save(commit=False)
            # print(f'Nome: {prod.nome}')
            # print(f'Preço: {prod.preco}')
            # print(f'Estoque: {prod.estoque}')
            # print(f'Imagem: {prod.imagem}')


apagar o diretório produtos
rodar e cadastrar novo produto
verificar o novo produto no mysql


(AULA-44)
refatorar o index.html, utiliznado uma table bootstrap4

{% load bootstrap4 %}
<!DOCTYPE html>
<html lang="pt-br">
<head>
    <meta charset="UTF-8">
    <title>Index</title>
    {% bootstrap_css %}
</head>
<body>
    <div class="container">
        <h1>Produtos</h1>

        <table class="table">
            <thead class="thead-dark">
                <tr>
                    <th scope="col">#</th>
                    <th scope="col">Produto</th>
                    <th scope="col">Preço</th>
                    <th scope="col">Estoque</th>
                </tr>
            </thead>
        <tbody>
            {% for produto in produtos %}
            <tr>
                <td scope="row">{{ produto.id }}</td>
                <td scope="row">{{ produto.nome }}</td>
                <td scope="row">{{ produto.preco }}</td>
                <td scope="row">{{ produto.estoque }}</td>
            </tr>
            {% endfor %}
        </tbody>
        </table>
    </div>

{% bootstrap_javascript jquery='full' %}
</body>


modal com link para mostrar uma imagem do produto:

<td scope="row"><a href="#modal{{ produto.id }}" data-toggle="modal">{{ produto.nome }}</a></td>

Criar o link para o arquivo styles.css

(AULA-45)
Seções do usuário

alterar o views.py....

if str(request.user) != 'AnonymousUser':
    ...
else:
    return redirect('index')