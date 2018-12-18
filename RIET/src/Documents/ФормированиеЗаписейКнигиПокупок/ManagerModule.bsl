
Функция ЗапросОстатковНДСПредъявленный(ДатаОстатков, ФормироватьПомесячно = Истина, ДополнительныеПараметрыВкладок = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	
	Если НЕ ФормироватьПомесячно Тогда
		Запрос.Параметры.Вставить("ДатаОстатков", 				Новый Граница(КонецКвартала(ДатаОстатков), ВидГраницы.Включая));
		Запрос.Параметры.Вставить("ДатаНалоговогоПериодаДляПП", КонецКвартала(ДатаОстатков));
	Иначе
		Запрос.Параметры.Вставить("ДатаОстатков", 				Новый Граница(КонецМесяца(ДатаОстатков), ВидГраницы.Включая));
		Запрос.Параметры.Вставить("ДатаНалоговогоПериодаДляПП", КонецМесяца(ДатаОстатков));
	КонецЕсли;
	ФормированиеЦелогоДокумента = ДополнительныеПараметрыВкладок = Неопределено;	
	Запрос.Параметры.Вставить("ИмяВкладки", 	 ?(ФормированиеЦелогоДокумента, Неопределено, ДополнительныеПараметрыВкладок.ИмяВкладки));
	Запрос.Параметры.Вставить("НалоговыйПериод", ?(ФормированиеЦелогоДокумента, Неопределено, НачалоКвартала(ДополнительныеПараметрыВкладок.НалоговыйПериод)));		

	Запрос.Текст = "ВЫБРАТЬ
	               |	СУММА(НДСПредъявленныйОстатки.СуммаБезНДСОстаток) КАК СуммаБезНДС,
	               |	ВЫБОР
	               |		КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПлатежноеПоручениеВходящее
	               |			ТОГДА НАЧАЛОПЕРИОДА(&ДатаНалоговогоПериодаДляПП, КВАРТАЛ)
				   // { RGS EKoshkina 09/15/2015 - не формировалась книга покупок
				   |		КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПоступлениеТоваровУслуг
	               |			ТОГДА НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.Дата, КВАРТАЛ)   
				   // } RGS EKoshkina 09/15/2015 - не формировалась книга покупок
	               |		ИНАЧЕ НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.НалоговыйПериод, КВАРТАЛ)
	               |	КОНЕЦ КАК НалоговыйПериод,
	               |	НДСПредъявленныйОстатки.СчетФактура,
	               |	НДСПредъявленныйОстатки.Поставщик,
	               |	НДСПредъявленныйОстатки.ВидВычета,
	               |	НДСПредъявленныйОстатки.ВидЦенности,
	               |	НДСПредъявленныйОстатки.Валюта,
	               |	СУММА(НДСПредъявленныйОстатки.НДСОстаток) КАК НДС,
	               |	СУММА(НДСПредъявленныйОстатки.СуммаБезНДСВВалютеОстаток) КАК СуммаБезНДСВВалюте,
	               |	СУММА(НДСПредъявленныйОстатки.НДСВВалютеОстаток) КАК НДСВВалюте,
	               |	НДСПредъявленныйОстатки.СтавкаНДС,
	               |	НДСПредъявленныйОстатки.ПодразделениеОрганизации,
	               |	НДСПредъявленныйОстатки.ДоговорКонтрагента
	               |ИЗ
	               |	РегистрНакопления.НДСПредъявленный.Остатки(&ДатаОстатков, ) КАК НДСПредъявленныйОстатки
	               |ГДЕ
	               |	ВЫБОР
	               |			КОГДА &ИмяВкладки = ""ВычетПоПриобретеннымЦенностям""
	               |				ТОГДА НДСПредъявленныйОстатки.ВидВычета = ЗНАЧЕНИЕ(Перечисление.ВидыНДСкВычету.ПредъявленПоставщиком)
	               |						И НЕ НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.РеализацияТоваровУслуг
	               |			КОГДА &ИмяВкладки = ""НДСсАвансов""
	               |				ТОГДА НДСПредъявленныйОстатки.ВидВычета = ЗНАЧЕНИЕ(Перечисление.ВидыНДСкВычету.НДСсАвансов)
	               |			КОГДА &ИмяВкладки = ""АгентскийНДС""
	               |				ТОГДА НДСПредъявленныйОстатки.ВидВычета = ЗНАЧЕНИЕ(Перечисление.ВидыНДСкВычету.АгентскийНДС)
	               |			КОГДА &ИмяВкладки = ""ВычетПриИзмененииСтоимостиВСторонуУменьшения""
	               |				ТОГДА НДСПредъявленныйОстатки.ВидВычета = ЗНАЧЕНИЕ(Перечисление.ВидыНДСкВычету.ПредъявленПоставщиком)
	               |						И НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.РеализацияТоваровУслуг
	               |			ИНАЧЕ ИСТИНА
	               |		КОНЕЦ
	               |	И ВЫБОР
	               |			КОГДА &НалоговыйПериод <> НЕОПРЕДЕЛЕНО
	               |				ТОГДА ВЫБОР
	               |						КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПлатежноеПоручениеВходящее
	               |							ТОГДА НАЧАЛОПЕРИОДА(&ДатаНалоговогоПериодаДляПП, КВАРТАЛ) = &НалоговыйПериод
				   // { RGS MYurkevich 7/24/2015 1:23:13 PM - 
				   |						КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПоступлениеТоваровУслуг
	               |							ТОГДА НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.Дата, КВАРТАЛ) = &НалоговыйПериод   
				   // } RGS MYurkevich 7/24/2015 1:23:14 PM - 
	               |						ИНАЧЕ НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.НалоговыйПериод, КВАРТАЛ) = &НалоговыйПериод
	               |					КОНЕЦ
	               |			ИНАЧЕ ИСТИНА
	               |		КОНЕЦ
	               |
	               |СГРУППИРОВАТЬ ПО
	               |	НДСПредъявленныйОстатки.СчетФактура,
	               |	НДСПредъявленныйОстатки.Поставщик,
	               |	НДСПредъявленныйОстатки.ВидВычета,
	               |	НДСПредъявленныйОстатки.ВидЦенности,
	               |	НДСПредъявленныйОстатки.Валюта,
	               |	НДСПредъявленныйОстатки.СтавкаНДС,
	               |	НДСПредъявленныйОстатки.ПодразделениеОрганизации,
	               |	НДСПредъявленныйОстатки.ДоговорКонтрагента,
	               |	ВЫБОР
	               |		КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПлатежноеПоручениеВходящее
	               |			ТОГДА НАЧАЛОПЕРИОДА(&ДатаНалоговогоПериодаДляПП, КВАРТАЛ)
				   // { RGS EKoshkina 09/15/2015 - не формировалась книга покупок
				   |		КОГДА НДСПредъявленныйОстатки.СчетФактура ССЫЛКА Документ.ПоступлениеТоваровУслуг
	               |			ТОГДА НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.Дата, КВАРТАЛ)   
				   // } RGS EKoshkina 09/15/2015 - не формировалась книга покупок
	               |		ИНАЧЕ НАЧАЛОПЕРИОДА(НДСПредъявленныйОстатки.СчетФактура.НалоговыйПериод, КВАРТАЛ)
	               |	КОНЕЦ
	               |
	               |УПОРЯДОЧИТЬ ПО
	               |	НалоговыйПериод";
				   
	   Если ФормированиеЦелогоДокумента Тогда		   
		   Запрос.Текст = Запрос.Текст + " 
		   |ИТОГИ ПО
		   |	НалоговыйПериод";
	   КонецЕсли;
	   
	   Возврат Запрос;
	
КонецФункции