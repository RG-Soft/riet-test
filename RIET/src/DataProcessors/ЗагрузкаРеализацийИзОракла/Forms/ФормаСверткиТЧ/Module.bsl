
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ЕдиницаИзмерения = Справочники.КлассификаторЕдиницИзмерения.НайтиПоКоду("796");
	
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	
	ЭтаФорма.Закрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура Ок(Команда)
	
	Если НЕ ЗначениеЗаполнено(Описание) ИЛИ НЕ ЗначениеЗаполнено(ЕдиницаИзмерения) Тогда
		Сообщить("Необходимо заполнить итоговые данные свертки!");
	Иначе
		ЭтаФорма.Закрыть(Новый Структура("Описание,ЕдиницаИзмерения",Описание,ЕдиницаИзмерения));  
	КонецЕсли;
	
КонецПроцедуры
