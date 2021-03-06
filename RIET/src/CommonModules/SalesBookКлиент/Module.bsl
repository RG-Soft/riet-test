
Процедура ОткрытьВыданныйСчетФактуру(Форма, СчетФактура) Экспорт

	СтандартнаяОбработка = Ложь;
 
	Если ЗначениеЗаполнено(СчетФактура) Тогда
		Параметры = Новый Структура("Ключ", СчетФактура);
	Иначе
		Если Форма.Объект.ПометкаУдаления Тогда
			Предупреждение(ВернутьСтр("ru = 'Счет-фактуру нельзя вводить на основании документа, помеченного на удаление.'"));
			Возврат;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Форма.Параметры.Ключ) Тогда
			Предупреждение(ВернутьСтр("ru = 'Документ не записан. Сначала следует записать документ.'"));
			Возврат;
		КонецЕсли;
		Если Форма.Модифицированность Тогда
			Предупреждение(ВернутьСтр("ru = 'Документ был изменен. Сначала следует записать документ.'"));
			Возврат;
		КонецЕсли;
		// { RGS MYurkevich 11/12/2015 12:15:15 PM - для печати
		//Если НЕ Форма.Объект.Проведен Тогда
		//	Предупреждение(ВернутьСтр("ru = 'Счет-фактуру нельзя вводить на основании не проведенного документа! Сначала следует провести документ.'"));
		//	Возврат;
		//КонецЕсли;
		// } RGS MYurkevich 11/12/2015 12:15:27 PM - для печати
		
		Параметры = Новый Структура("Основание", Форма.Параметры.Ключ);
	КонецЕсли;
	
	ФормаСФ = ОткрытьФорму("Документ.СчетФактураВыданный.ФормаОбъекта", Параметры, Форма);
		
КонецПроцедуры

Процедура ОткрытьСчетНаОплатуПокупателю(Форма, СчетНаОплату) Экспорт

	СтандартнаяОбработка = Ложь;
 
	Если ЗначениеЗаполнено(СчетНаОплату) Тогда
		Параметры = Новый Структура("Ключ", СчетНаОплату);
	Иначе
		Если Форма.Объект.ПометкаУдаления Тогда
			Предупреждение(ВернутьСтр("ru = 'Счет на оплату нельзя вводить на основании документа, помеченного на удаление.'"));
			Возврат;
		КонецЕсли;
		Если НЕ ЗначениеЗаполнено(Форма.Параметры.Ключ) Тогда
			Предупреждение(ВернутьСтр("ru = 'Документ не записан. Сначала следует записать документ.'"));
			Возврат;
		КонецЕсли;
		Если Форма.Модифицированность Тогда
			Предупреждение(ВернутьСтр("ru = 'Документ был изменен. Сначала следует записать документ.'"));
			Возврат;
		КонецЕсли;
		Если НЕ Форма.Объект.Проведен Тогда
			Предупреждение(ВернутьСтр("ru = 'Счет на оплату нельзя вводить на основании не проведенного документа! Сначала следует провести документ.'"));
			Возврат;
		КонецЕсли;

		Параметры = Новый Структура("Основание", Форма.Параметры.Ключ);
	КонецЕсли;
	
	ФормаСчета = ОткрытьФорму("Документ.СчетНаОплатуПокупателю.ФормаОбъекта", Параметры, Форма);
		
КонецПроцедуры

// Процедура активизирует элемент формы.
// Если это - табличная часть, то тогда анализируется,
// может табличная часть на закладке и если так,
// то закладка становится текущей, но табличная часть не активизируется
//
// Параметры:
//  Форма            - Управляемая форма
//  ИмяЭлементаФормы - Строка - имя элемента, который необходимо активизировать
//
Процедура АктивизироватьЭлементФормы(Форма, ИмяЭлементаФормы) Экспорт

	Если НЕ ПустаяСтрока(ИмяЭлементаФормы) Тогда
		НайденныйЭлементФормы = Форма.Элементы.Найти(ИмяЭлементаФормы);
		Если НайденныйЭлементФормы <> Неопределено Тогда
			Если ТипЗнч(НайденныйЭлементФормы) = Тип("ТаблицаФормы") Тогда
				// Для таблицы определить - если она находится на закладке, то не активизировать элемент,
				// а сделать активной страницу, на которой находится эта табличная часть
				Страница = НайденныйЭлементФормы.Родитель;
				Если (Страница <> Неопределено) И (Страница.Вид = ВидГруппыФормы.Страница) Тогда
					// Определим владельца этой страницы и активизируем эту страницу
					ПанельСтраниц = Страница.Родитель;
					Если (ПанельСтраниц <> Неопределено) И (ПанельСтраниц.Вид = ВидГруппыФормы.Страницы) Тогда
						ПанельСтраниц.ТекущаяСтраница = Страница;
					Иначе
						Форма.ТекущийЭлемент = НайденныйЭлементФормы;
					КонецЕсли;
				Иначе
					Форма.ТекущийЭлемент = НайденныйЭлементФормы;
				КонецЕсли;
			Иначе
				Форма.ТекущийЭлемент = НайденныйЭлементФормы;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры
   
Процедура ВыборРасчетногоДокумента(СтруктураПараметров, Элемент, ТипыДокументов) Экспорт

	ПараметрыОбъекта = Новый Структура;
	ПараметрыОбъекта.Вставить("Организация",СтруктураПараметров.Организация);
	ПараметрыОбъекта.Вставить("Контрагент",СтруктураПараметров.Контрагент);
	ПараметрыОбъекта.Вставить("ДоговорКонтрагента",СтруктураПараметров.ДоговорКонтрагента);
	Если СтруктураПараметров.Свойство("СчетДляОпределенияОстатков") Тогда 
		ПараметрыОбъекта.Вставить("Счет",СтруктураПараметров.СчетДляОпределенияОстатков);
	КонецЕсли;
	ПараметрыОбъекта.Вставить("ОстаткиОбороты", ?(СтруктураПараметров.СторонаСчета = "Дт", 0, 1));
	Если СтруктураПараметров.Свойство("РежимОтбораДокументов") Тогда 
		ПараметрыОбъекта.Вставить("РежимОтбораДокументов",СтруктураПараметров.РежимОтбораДокументов);
	КонецЕсли;
	ПараметрыОбъекта.Вставить("РежимВыбора",Истина);
	ПараметрыОбъекта.Вставить("ТипыДокументов",ТипыДокументов);

	Если СтруктураПараметров.Свойство("ЭтоНовыйДокумент") и СтруктураПараметров.ЭтоНовыйДокумент Тогда 
		ПараметрыОбъекта.Вставить("КонПериода",КонецДня(ТекущаяДата()));
	Иначе
		ПараметрыОбъекта.Вставить("КонПериода",СтруктураПараметров.КонецПериода);
	КонецЕсли;
	
	Если СтруктураПараметров.Свойство("НачалоПериода") Тогда
		ПараметрыОбъекта.Вставить("НачПериода",СтруктураПараметров.НачалоПериода);
		ПараметрыОбъекта.Вставить("мПереданИнтервал",Истина);
	Иначе
		ПараметрыОбъекта.Вставить("мПереданИнтервал",Ложь);
	КонецЕсли;

	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("ПараметрыОбъекта", ПараметрыОбъекта);

	ОткрытьФорму("Документ.ДокументРасчетовСКонтрагентом.Форма.ФормаВыбораУправляемая", ПараметрыФормы, Элемент, Истина);

КонецПроцедуры
