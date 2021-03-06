
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Элементы.Список.РежимВыбора = Параметры.РежимВыбора;
	
	КонтрольПредопределенных();
КонецПроцедуры
Процедура КонтрольПредопределенных()
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	               |	rgsReasonsForTR.Ссылка,
	               |	rgsReasonsForTR.ИмяПредопределенныхДанных
	               |ИЗ
	               |	Справочник.rgsReasonsForTR КАК rgsReasonsForTR
	               |ГДЕ
	               |	rgsReasonsForTR.Предопределенный
	               |	И rgsReasonsForTR.EnglishName = """"";
	
	Рез = Запрос.Выполнить();
	Если Рез.Пустой() Тогда Возврат КонецЕсли;
	
	Выб = Рез.Выбрать();
	Пока Выб.Следующий() Цикл
		ТекОбъект = Выб.Ссылка.ПолучитьОбъект();
		ТекОбъект.EnglishName = выб.ИмяПредопределенныхДанных;
		Попытка
			ТекОбъект.Записать();
		Исключение
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры
