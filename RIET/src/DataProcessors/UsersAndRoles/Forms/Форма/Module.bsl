
///////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЗаполнитьТаблицуUsersRoles();
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьТаблицуUsersRoles() 
	
	ТаблицаUsersRoles.Очистить();
	
	ДобавитьКолонкиРолейВТаблицу();
	
	УстановитьПривилегированныйРежим(Истина);
	
	//получаем таблицу значений с данными из справочника пользователи
	ТаблицаДанныхПользователя = ПолучитьТаблицуДанныхПользователей();
	
	//заполняем таблицу	
	МассивПользователейИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
		
	Для Каждого ПользовательИБ Из МассивПользователейИБ Цикл
		
		// Если у пользователя нет способа зайти в базу - будем считать, что его нет
		Если НЕ ПользовательИБ.АутентификацияОС И НЕ ПользовательИБ.АутентификацияСтандартная Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаТаблицыПользователей = ТаблицаДанныхПользователя.Найти(ПользовательИБ.Имя, "UserAlias");	
		Если СтрокаТаблицыПользователей = Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		НоваяСтрока = ТаблицаUsersRoles.Добавить();
		НоваяСтрока.UserAlias = ПользовательИБ.Имя;
		НоваяСтрока.UserName = ПользовательИБ.ПолноеИмя;
		НоваяСтрока.PasswordAuthorization = ПользовательИБ.АутентификацияСтандартная;
		НоваяСтрока.OSAuthorization = ПользовательИБ.АутентификацияОС;
		НоваяСтрока.Language = СокрЛП(ПользовательИБ.Язык);
		
		Для Каждого Роль Из ПользовательИБ.Роли Цикл
			НоваяСтрока[Роль.Имя] = Истина;
		КонецЦикла;
		
		ЗаполнитьЗначенияСвойств(НоваяСтрока, СтрокаТаблицыПользователей, 
			"User, ProcessLevelCode, EMail");
			
	КонецЦикла;	
	
КонецПроцедуры

&НаСервере
Процедура ДобавитьКолонкиРолейВТаблицу() 
			
	Роли = Метаданные.Роли;
	
	ОписаниеТиповСтрока = Новый ОписаниеТипов("Строка");
	ДобавляемыеКолонки = Новый Массив;
	Для Каждого Роль Из Роли Цикл
		
		НазваниеРоли = СокрЛП(Роль.Имя);
		
		//добавляем реквизит таблицы значений
		НоваяКолонка = Новый РеквизитФормы(НазваниеРоли, ОписаниеТиповСтрока, "ТаблицаUsersRoles", СокрЛП(Роль.Синоним));
				
		ДобавляемыеКолонки.Добавить(НоваяКолонка);
		
	КонецЦикла;	
	
	ИзменитьРеквизиты(ДобавляемыеКолонки);
	
	Для Каждого Роль Из Роли Цикл
		
		НазваниеРоли = СокрЛП(Роль.Имя);
        		
		//добавляем элемент поле формы
		НовоеПоле = Элементы.Добавить("ТаблицаUsersRoles"+НазваниеРоли, Тип("ПолеФормы"), Элементы.ТаблицаUsersRoles);
		
		НовоеПоле.ПутьКДанным = "ТаблицаUsersRoles." + НазваниеРоли;
		НовоеПоле.Вид = ВидПоляФормы.ПолеВвода;
		НовоеПоле.ТолькоПросмотр = Истина;
		НовоеПоле.Ширина = 10;
		    				
	КонецЦикла;
	   	
КонецПроцедуры

&НаСервере
Функция ПолучитьТаблицуДанныхПользователей()

	Запрос = Новый Запрос;
	Запрос.Текст =
		"ВЫБРАТЬ
		|	Пользователи.Ссылка КАК User,
		|	ВЫРАЗИТЬ(Пользователи.Код КАК СТРОКА(50)) КАК UserAlias,
		|	Пользователи.EMail,
		|	Пользователи.ProcessLevel.Код КАК ProcessLevelCode
		|ИЗ
		|	Справочник.Пользователи КАК Пользователи
		|ГДЕ
		|	НЕ Пользователи.ЭтоГруппа
		|	И НЕ Пользователи.ПометкаУдаления";
				   
	ТЗ = Запрос.Выполнить().Выгрузить();
	
	Для Каждого Стр Из ТЗ Цикл 
		Стр.UserAlias = СокрЛП(Стр.UserAlias);
	КонецЦикла;
	
	ТЗ.Индексы.Добавить("UserAlias");
	
	Возврат ТЗ;
		      
КонецФункции 


///////////////////////////////////////////////////////////////////////////////////////////
// ОБРАБОТЧИКИ СОБЫТИЙ ТАБЛИЦЫ USERS ROLES

&НаКлиенте
Процедура ТаблицаUsersRolesВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;
	
	ТекUser = Элементы.ТаблицаUsersRoles.ТекущиеДанные.User;
	Если ЗначениеЗаполнено(ТекUser) Тогда
		ПоказатьЗначение(,ТекUser);
	КонецЕсли;
      	
КонецПроцедуры


///////////////////////////////////////////////////////////////////////////////////////////
// КОМАНДА  Selected E-mails

&НаКлиенте
Процедура SelectedEmails(Команда)
	
	ТекстДок = ПолучитьТекстовыйДокументWithSelectedEmails();
    ТекстДок.Показать("Selected e-mails"); 
	
КонецПроцедуры

&НаКлиенте
Функция ПолучитьТекстовыйДокументWithSelectedEmails()
	
	SelectedEmails = "";
	
	Для Каждого ВыделеннаяСтрока из Элементы.ТаблицаUsersRoles.ВыделенныеСтроки Цикл
		
		СтрокаТаб = ТаблицаUsersRoles.НайтиПоИдентификатору(ВыделеннаяСтрока);
		Разделитель = ?(ПустаяСтрока(SelectedEmails), "", ", ");
		
		SelectedEmails = SelectedEmails + Разделитель + 
						 ?(ПустаяСтрока(СтрокаТаб.EMail), "", СтрокаТаб.EMail);
		
	КонецЦикла;
	
	ТекстДок = Новый ТекстовыйДокумент;
	ТекстДок.ДобавитьСтроку(SelectedEmails);
	
    Возврат ТекстДок;
	
КонецФункции

///////////////////////////////////////////////////////////////////////////////////////////
// КОМАНДА  Change Language

&НаКлиенте
Процедура ChangeLanguage(Команда)
	
	МассивUsers = Новый Массив;
	
	Для Каждого ВыделеннаяСтрока из Элементы.ТаблицаUsersRoles.ВыделенныеСтроки Цикл
		
		СтрокаТаб = ТаблицаUsersRoles.НайтиПоИдентификатору(ВыделеннаяСтрока);
		
		NewLanguage = ChangeLanguageНаСервере(СтрокаТаб.UserAlias);
		
		СтрокаТаб.Language = NewLanguage;
		
	КонецЦикла;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ChangeLanguageНаСервере(UserAlias)
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоИмени(UserAlias);
	ПользовательИБ.Язык = ?(ПользовательИБ.Язык = Метаданные.Языки.Английский, 
		Метаданные.Языки.Русский, Метаданные.Языки.Английский);
	ПользовательИБ.Записать();
		
	УстановитьПривилегированныйРежим(Ложь);
	
	Возврат СокрЛП(ПользовательИБ.Язык);
	
КонецФункции


