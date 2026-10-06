trigger ContatoTrigger on Contact (before insert, before update, after insert) {
    if (Trigger.isBefore) {
        for (Contact contato : Trigger.new) {
            if (String.isBlank(contato.LastName)) {
                contato.addError('Sobrenome obrigatorio.');
            }
            if (String.isBlank(contato.Email)) {
                contato.addError('Email obrigatorio.');
            }
            if (String.isBlank(contato.Phone)) {
                contato.addError('Telefone obrigatorio.');
            }
        }
    }
}