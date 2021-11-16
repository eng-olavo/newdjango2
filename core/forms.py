from django import forms
from django.core.mail.message import EmailMessage
from .models import Produto

class ContatoForm(forms.Form):
    nome = forms.CharField(label='Nome', max_length=128)
    email = forms.EmailField(label='E-Mail', max_length=128)
    assunto = forms.CharField(label='Assunto', max_length=128)
    mensagem = forms.CharField(label='Mensagem', widget=forms.Textarea())

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
            to=['contato@seudominio.com.br',],
            headers={'Reply-to': email}
        )
        mail.send()


class ProdutoModelForm(forms.ModelForm):

    class Meta:
        model = Produto
        fields = ['nome', 'preco', 'estoque', 'imagem']