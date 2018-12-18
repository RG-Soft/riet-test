
/////////////////////////////////////////////////////////////////////////////////////
// ТАБЛИЧНАЯ ЧАСТЬ PORTS

&НаКлиенте
Процедура PortsПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель, Группа)
	
	Отказ = Истина;
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ВыборГруппИЭлементов", ИспользованиеГруппИЭлементов.ГруппыИЭлементы);
	ПараметрыФормы.Вставить("МножественныйВыбор", Истина);
	ОткрытьФорму("Справочник.SeaAndAirPorts.ФормаВыбора", ПараметрыФормы, Элемент);
	
КонецПроцедуры

&НаКлиенте
Процедура PortsОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	
	Если ТипЗнч(ВыбранноеЗначение) = Тип("Массив")
		И ВыбранноеЗначение.Количество() > 0
		И ТипЗнч(ВыбранноеЗначение[0]) = Тип("СправочникСсылка.SeaAndAirPorts") Тогда
		
		СтандартнаяОбработка = Ложь;
		
		Для Каждого Значение Из ВыбранноеЗначение Цикл
			НоваяСтрока = Объект.Ports.Добавить();
			НоваяСтрока.Port = Значение;
		КонецЦикла;
		
		Модифицированность = Истина;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура PortsВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ТекущиеДанные = Элемент.ТекущиеДанные;
	Если ТекущиеДанные <> Неопределено
		И ЗначениеЗаполнено(ТекущиеДанные.Port) Тогда
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(,ТекущиеДанные.Port);
	КонецЕсли; 
	
КонецПроцедуры
