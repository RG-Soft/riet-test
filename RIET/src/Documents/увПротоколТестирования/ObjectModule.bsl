////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ДОКУМЕНТА

// Процедура - обработчик события "ОбработкаЗаполнения" документа
//
Процедура ОбработкаЗаполнения(Основание)
	
	Если Основание = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ТипЗнч(Основание) = Тип("ДокументСсылка.увЗаявкаНаВыполнениеРабот") Тогда
		
		//Нумерация рассчитана на длину строкового номера документа заявки равную 5
		//если в заявке длина номера изменена то в ПТ нужно ставить длину равную 
		//ДлинаНомераЗаявки + 3
		
		ПоследнийНомер = 0;
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
		               |	ПротоколТестирования.Номер,
		               |	ПротоколТестирования.ЗаявкаНаВыполнениеРабот
		               |ИЗ
		               |	Документ.увПротоколТестирования КАК ПротоколТестирования
		               |
		               |ГДЕ
		               |	ПротоколТестирования.ЗаявкаНаВыполнениеРабот = &Заявка";
		Запрос.УстановитьПараметр("Заявка", Основание);
		Результат = Запрос.Выполнить();
		Выборка = Результат.Выбрать();
		Пока Выборка.Следующий() Цикл
			СтрокаНомера = Выборка.Номер;
			НомерПТ = Число(Прав(СтрокаНомера,2));
			ПоследнийНомер = ?(НомерПТ > ПоследнийНомер, НомерПТ, ПоследнийНомер);
		КонецЦикла;
		ПоследнийНомер = (ПоследнийНомер+1);
		Если ПоследнийНомер < 10 Тогда
			Номер = Основание.Номер + "-0" + ПоследнийНомер;
		Иначе
			Номер = Основание.Номер + "-" + ПоследнийНомер;
		КонецЕсли;
		ЗаявкаНаВыполнениеРабот = Основание.Ссылка;
		ПредставительЗаказчика = Основание.ОтветственныйЗаВнедрениеОтЗаказчика;
		ПредставительИсполнителя = Основание.ОтветственныйЗаТестирование;
		Статус = Перечисления.увСтатусПротоколаТестирования.НетПретензий;
	КонецЕсли;

КонецПроцедуры

// Процедура - обработчик события "ПередЗаписью" документа
//
Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	Если Не ЗначениеЗаполнено(Дата) Тогда	
		Сообщить("Не заполнено поле: Дата");
		Отказ = Истина;
	ИначеЕсли Не ЗначениеЗаполнено(Номер) Тогда	
		Сообщить("Не заполнено поле: Номер");
		Отказ = Истина;
	ИначеЕсли Не ЗначениеЗаполнено(Статус) Тогда
		Отказ = Истина;
	ИначеЕсли Статус = Перечисления.увСтатусПротоколаТестирования.НетПретензий Тогда
		Если Не ЗначениеЗаполнено(ДатаЗакрытияТестирования) Тогда
			Сообщить("Не заполнено поле: Дата закрытия тестирования");
			Отказ = Истина; 
		КонецЕсли;
	Иначе 
		Если Не ЗначениеЗаполнено(СледующаяВстреча) Тогда
			Сообщить("Не заполнено поле: Следующая встреча");
			Отказ = Истина; 
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры


