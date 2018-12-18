
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Для каждого Условие Из Параметры.СписокПараметров Цикл
		СтрокаТЧ = ПараметрыПечати.Добавить();
		СтрокаТЧ.ИмяПараметра = Условие.Значение;
	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура Отмена(Команда)
	ЭтаФорма.Закрыть(Новый Массив);
КонецПроцедуры

&НаКлиенте
Процедура ОК(Команда)
	МассивВозврата = Новый Массив;
	Для Инд = 1 По ПараметрыПечати.Количество() Цикл
		Если ПараметрыПечати[Инд - 1].Значение Тогда
		    МассивВозврата.Добавить(Инд);
		КонецЕсли; 
	КонецЦикла; 
	ЭтаФорма.Закрыть(МассивВозврата);	
КонецПроцедуры


