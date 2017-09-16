# TODO-LIST


## How Execute

1. Go to folder TODO_list cd backend/TODO_list
2. Create VirtualEnv, [Tutorial]: http://www.pythonforbeginners.com/basics/how-to-use-python-virtualenv
3. Install packaged requirements. Type pip install -r requirements/dev.txt
4. Execute server: python manage.py runserver --settings=TODO_list.settings.dev
5. Open Browser
6. Type http://127.0.0.1:8000/tasks/



## How Test

1. Go to folder TODO_list cd backend/TODO_list
2. Create VirtualEnv, [Tutorial]: http://www.pythonforbeginners.com/basics/how-to-use-python-virtualenv
3. Install packaged requirements. Type pip install -r requirements/dev.txt
4. Execute: coverage run manage.py test apps.todo --settings=TODO_list.settings.dev

* Some things are needed to the selenium tests.


## How to Use TODO-LIst
1. How to Create a Task?
    1. Click in btn with text "Criar Nova Tarefa"
    2. Input the title and description
    3. Click in btn with text "Salvar"
    4. Task will be created.

2. How to Edit a Task?
    1. Click on the btn with text "Detalhes"
    2. Input title, description or status
    3. Click on the btn with text "Salvar"
    4. Task will be updated

3. How to change the order?
    1. Drag the task to another task.
    2. This operation is put the task in that place.

4. How to Delete a Task?
    1. Click on the btn with text "Detalhes"
    2. Input title, description or status
    3. Click on the btn with text "Remover"
    4. Click on the btn with text "Sim"
    5. Task will be updated.

5. How to Set 'Feitas'?
    1. Click on the btn with text "Detalhes"
    2. Input status Feitas
    3. Click on the btn with text "Salvar"
    4. Task will be updated
