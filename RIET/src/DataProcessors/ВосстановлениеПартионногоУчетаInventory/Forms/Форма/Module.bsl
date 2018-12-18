
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьИнформационныеНадписи();
	
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	
	ОбновитьИнформационныеНадписи();
	
КонецПроцедуры

&НаКлиенте
Процедура РассчитатьСебестоимость(Команда)
	
	РассчитатьСебестоимостьНаСервере();
	
КонецПроцедуры

&НаСервере
Процедура РассчитатьСебестоимостьНаСервере()
	
	InventoryСервер.ВосстановитьПартионныйУчет(РассчитатьСебестоимостьДо);
	ОбновитьИнформационныеНадписи();
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьИнформационныеНадписи()
	
	Структура = ПолучитьТекущуюГраницуИПоследнийДокумент();
	ПериодТекущейГраницы = Структура.ПериодГраницы;
	ДокументТекущейГраницы = Структура.ДокументГраницы;
	ПериодПоследнегоДокумента = Структура.ПериодПоследнегоДокумента;
	ПоследнийДокумент = Структура.ПоследнийДокумент;
	РассчитатьСебестоимостьДо = ПериодПоследнегоДокумента;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьТекущуюГраницуИПоследнийДокумент()
	
	Структура = Новый Структура("ПериодГраницы, ДокументГраницы, ПериодПоследнегоДокумента, ПоследнийДокумент");
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	InventoryПартииГраницы.Период,
		|	InventoryПартииГраницы.Регистратор
		|ИЗ
		|	Последовательность.InventoryBatches.Границы КАК InventoryПартииГраницы
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ ПЕРВЫЕ 1
		|	InventoryПартии.Регистратор,
		|	InventoryПартии.Период
		|ИЗ
		|	Последовательность.InventoryBatches КАК InventoryПартии
		|ГДЕ
		|	(НЕ InventoryПартии.Регистратор.ПометкаУдаления)
		|
		|УПОРЯДОЧИТЬ ПО
		|	InventoryПартии.МоментВремени УБЫВ";
	Результаты = Запрос.ВыполнитьПакет();
	
	ВыборкаГраницы = Результаты[0].Выбрать();
	Если ВыборкаГраницы.Следующий() Тогда
		Структура.ПериодГраницы = ВыборкаГраницы.Период;
		Структура.ДокументГраницы = ВыборкаГраницы.Регистратор;
	КонецЕсли;
	
	ВыборкаПоследнегоДокумента = Результаты[1].Выбрать();
	Если ВыборкаПоследнегоДокумента.Следующий() Тогда
		Структура.ПериодПоследнегоДокумента = ВыборкаПоследнегоДокумента.Период;
		Структура.ПоследнийДокумент = ВыборкаПоследнегоДокумента.Регистратор;
	КонецЕсли;
	
	Возврат Структура;
	
КонецФункции

