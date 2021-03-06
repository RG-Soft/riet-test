
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Параметры.Свойство("ТабЗнач") Тогда
		ТабЗнач = Параметры.ТабЗнач;
		ТабСоответствий.Загрузить(ТабЗнач);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура Записать(Команда)
	ЗаписатьНаСервере();
КонецПроцедуры

&НаСервере
Процедура ЗаписатьНаСервере()
	Для каждого Строка Из ТабСоответствий Цикл
		НовыйЭлемент = Справочники.ВидыНачислений.СоздатьЭлемент();
		НовыйЭлемент.Наименование = Строка.ВидНачисления;
		НовыйЭлемент.ТипНачисления = Строка.ТипНачисления;
		НовыйЭлемент.Записать();
	КонецЦикла; 
КонецПроцедуры
