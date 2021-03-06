// Настройка периода
Перем НП Экспорт;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ 
// 

Процедура СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок = Ложь, ВысотаЗаголовка = 0, ТолькоЗаголовок = Ложь) Экспорт

	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "Организация", Организация);
	
	Если ОтчетПоДокументу Тогда
		МоментДокумента = новый МоментВремени(Документ.Дата,Документ);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаНачала", МоментДокумента.Дата);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаОкончания", МоментДокумента.Дата);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "НачГраница", МоментДокумента);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "КонГраница", МоментДокумента);
		
	Иначе
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаНачала", ОбщийОтчет.ДатаНач);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ДатаОкончания", ОбщийОтчет.ДатаКон);
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "НачГраница", ОбщийОтчет.ДатаНач);//Новый Граница( , ВидГраницы.Исключая));
		ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "КонГраница", Новый Граница( ОбщийОтчет.ДатаКон, ВидГраницы.Включая));
	КонецЕсли; 
	
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "ПустаяДата", '00010101');
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СостояниеПринятоКУчету",	  Перечисления.СостоянияОС.ПринятоКУчету);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СостояниеСнятоСУчета", 	  Перечисления.СостоянияОС.СнятоСУчета);
	ОбщийОтчет.ПостроительОтчета.Параметры.Вставить( "СубконтоОС",				  ПланыВидовХарактеристик.ВидыСубконтоХозрасчетные.ОсновныеСредства);
	ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке = Истина;
	
	ОбщийОтчет.СформироватьОтчет(ДокументРезультат, ПоказыватьЗаголовок, ВысотаЗаголовка, ТолькоЗаголовок);

КонецПроцедуры // СформироватьОтчет()

// Процедура - заполняет начальные настройки отчета
//
Процедура ЗаполнитьНачальныеНастройки() Экспорт
	
	ПостроительОтчета = ОбщийОтчет.ПостроительОтчета;
	ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке = Истина;
	
	Текст =
	"ВЫБРАТЬ
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство КАК ОсновноеСредство,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.Местонахождение КАК Подразделение,
	//|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ,
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство.ПодлежитАмортизации КАК ПодлежитАмортизации,
	|	ВЫБОР КОГДА (СнятыеСУчета.СнятоСУчета) ЕСТЬ NULL  ТОГДА ЛОЖЬ ИНАЧЕ СнятыеСУчета.СнятоСУчета КОНЕЦ КАК ОССнятоСУчетаНаНачало,
	//|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.СписаноПриПринятииКУчету КАК СписаноПриПринятииКУчету,
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.МетодНачисленияАмортизации,
	|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СрокПолезногоИспользования КАК СрокИспользованияДляВычисленияАмортизации,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОбъемПродукцииРаботДляВычисленияАмортизации,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентАмортизации,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентУскорения,
	//|	ГрафикиАмортизацииБухгалтерскийУчетСрезПоследних.ГрафикАмортизации,
	//|	СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетУчета,
	//|	СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетНачисленияАмортизации,
	|	НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.НачислятьАмортизацию,
	//|	ТекущееСостояние.ДатаСостояния как ДатаПоследнегоСостояния,
	|	ТекущееСостояние.Состояние как ЗначениеТекущегоСостояния,
	//|	СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних.СпособыОтраженияРасходовПоАмортизации,
	|	СУММА(ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ПервоначальнаяСтоимостьНУ) КАК ПервоначальнаяСтоимость,
	//|	СУММА(Выбор когда ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СтоимостьДляВычисленияАмортизации есть null тогда 0 иначе ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СтоимостьДляВычисленияАмортизации конец) КАК СтоимостьДляВычисленияАмортизации,
	|	СУММА(Выбор когда СтоимостьОС_БУ.СуммаНачальныйОстатокДт  есть Null тогда 0 иначе  СтоимостьОС_БУ.СуммаНачальныйОстатокДт  конец) КАК СтоимостьНачальныйОстаток,
	|	СУММА(Выбор когда АмортизацияОС_БУ.СуммаНачальныйОстатокКт  есть Null тогда 0 иначе АмортизацияОС_БУ.СуммаНачальныйОстатокКт  конец) КАК АмортизацияНачальныйОстаток,
	|	СУММА(Выбор когда СтоимостьОС_БУ.СуммаОборотДт  есть Null тогда 0 иначе  СтоимостьОС_БУ.СуммаОборотДт  конец) КАК СтоимостьОборотДт,
	|	СУММА(Выбор когда СтоимостьОС_БУ.СуммаОборотКт  есть Null тогда 0 иначе  СтоимостьОС_БУ.СуммаОборотКт конец) КАК СтоимостьОборотКт,
	|	СУММА(Выбор когда АмортизацияОС_БУ.СуммаОборотКт  есть Null тогда 0 иначе АмортизацияОС_БУ.СуммаОборотКт конец) КАК АмортизацияОборот,
	|	СУММА(Выбор когда СтоимостьОС_БУ.СуммаКонечныйОстатокДт есть Null тогда 0 иначе СтоимостьОС_БУ.СуммаКонечныйОстатокДт конец) КАК СтоимостьКонечныйОстаток,
	|	СУММА(выбор когда АмортизацияОС_БУ.СуммаКонечныйОстатокКт есть null тогда 0 иначе АмортизацияОС_БУ.СуммаКонечныйОстатокКт конец) КАК АмортизацияКонечныйОстаток,
	|	СУММА((Выбор когда СтоимостьОС_БУ.СуммаКонечныйОстатокДт есть Null тогда 0 иначе СтоимостьОС_БУ.СуммаКонечныйОстатокДт конец) - (выбор когда АмортизацияОС_БУ.СуммаКонечныйОстатокКт есть null тогда 0 иначе АмортизацияОС_БУ.СуммаКонечныйОстатокКт конец)) КАК ОстаточнаяСтоимость,
	|	СУММА(ВЫРАЗИТЬ(ВыработкаОСОбороты.КоличествоОборот КАК ЧИСЛО(15, 2))) КАК Выработка
	|{ВЫБРАТЬ
	|		МестонахождениеОСБухгалтерскийУчетСрезПоследних.Местонахождение КАК Подразделение,
	|		МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ,
	|		ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство.*,
	|		ПринятиеКУчету.ДатаСостояния как ДатаПринятияКУчету,
	//|		ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.СписаноПриПринятииКУчету,
	//|		ОССнятоСУчетаНаНачало,
	|		СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетУчета,
	|		СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетНачисленияАмортизации,
	|		ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.МетодНачисленияАмортизации,
	|		ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СрокПолезногоИспользования КАК СрокИспользованияДляВычисленияАмортизации,
	//|		ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОбъемПродукцииРаботДляВычисленияАмортизации,
	//|		ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентАмортизации,
	//|		ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентУскорения,
	|		ГрафикиАмортизацииБухгалтерскийУчетСрезПоследних.ГрафикАмортизации,
	|		СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних.СпособыОтраженияРасходовПоАмортизации,
	|		ТекущееСостояние.ДатаСостояния  как ДатаПоследнегоСостояния
	//|		,ТекущееСостояние.Состояние Как ЗначениеТекущегоСостояния
	|	}
	|ИЗ
	|	РегистрСведений.ПервоначальныеСведенияОСНалоговыйУчет.СрезПоследних(&КонГраница, Организация = &Организация {ОсновноеСредство.* КАК ОсновноеСредство}) КАК ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ВыработкаОС.Обороты(&НачГраница, &КонГраница, , ) КАК ВыработкаОСОбороты
	|		ПО ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство = ВыработкаОСОбороты.ОсновноеСредство 
	//И ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ПараметрВыработки = ВыработкаОСОбороты.ПараметрВыработки
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.МестонахождениеОСБухгалтерскийУчет.СрезПоследних(&КонГраница, Организация = &Организация) КАК МестонахождениеОСБухгалтерскийУчетСрезПоследних
	|	ПО ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство = МестонахождениеОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НачислениеАмортизацииОСНалоговыйУчет.СрезПоследних(&КонГраница, Организация = &Организация) КАК НачислениеАмортизацииБухгалтерскийУчетСрезПоследних
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ПараметрыАмортизацииОСНалоговыйУчет.СрезПоследних(&КонГраница, Организация = &Организация) КАК ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ГрафикиАмортизацииОСБухгалтерскийУчет.СрезПоследних(&КонГраница, Организация = &Организация) КАК ГрафикиАмортизацииБухгалтерскийУчетСрезПоследних
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ГрафикиАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СпособыОтраженияРасходовПоАмортизацииОСНалоговыйУчет.СрезПоследних(&КонГраница, Организация = &Организация) КАК СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СчетаНалоговогоУчетаОС.СрезПоследних(&КонГраница, Организация = &Организация) КАК СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних
	|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Налоговый.ОстаткиИОбороты(&НачГраница, &КонГраница, Период,ДвиженияИГраницыПериода , , &СубконтоОС, Организация = &Организация) КАК СтоимостьОС_БУ
	|				ПО СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.ОсновноеСредство = СтоимостьОС_БУ.Субконто1 И СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетУчета = СтоимостьОС_БУ.Счет
	|				ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Налоговый.ОстаткиИОбороты(&НачГраница, &КонГраница, Период,ДвиженияИГраницыПериода , , &СубконтоОС, Организация = &Организация) КАК АмортизацияОС_БУ
	|				ПО СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.ОсновноеСредство = АмортизацияОС_БУ.Субконто1 И СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетНачисленияАмортизации = АмортизацияОС_БУ.Счет
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|				СостоянияОСОрганизаций.ОсновноеСредство КАК ОсновноеСредство, Истина как СнятоСУчета
	|			ИЗ
	|				РегистрСведений.СостоянияОСОрганизаций КАК СостоянияОСОрганизаций
	|			
	|			ГДЕ
	|				СостоянияОСОрганизаций.Состояние = &СостояниеСнятоСУчета И
	|				СостоянияОСОрганизаций.ДатаСостояния < &ДатаНачала И
	|				СостоянияОСОрганизаций.Организация = &Организация) КАК СнятыеСУчета
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = СнятыеСУчета.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|				СостоянияОСОрганизаций.ОсновноеСредство КАК ОсновноеСредство,
	|               СостоянияОСОрганизаций.ДатаСостояния
	|			ИЗ
	|				РегистрСведений.СостоянияОСОрганизаций КАК СостоянияОСОрганизаций
	|			
	|			ГДЕ
	|				СостоянияОСОрганизаций.Состояние = &СостояниеПринятоКУчету И
	|				(выбор когда &ДатаОкончания = &ПустаяДата тогда истина иначе СостоянияОСОрганизаций.ДатаСостояния <= &ДатаОкончания конец) И
	|				СостоянияОСОрганизаций.Организация = &Организация) КАК ПринятиеКУчету
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ПринятиеКУчету.ОсновноеСредство
	|			ЛЕВОЕ СОЕДИНЕНИЕ (ВЫБРАТЬ
	|				СостоянияОСОрганизаций.ОсновноеСредство КАК ОсновноеСредство,
	|				СостоянияОСОрганизаций.Состояние КАК Состояние,
	|				СостоянияОСОрганизаций.ДатаСостояния КАК ДатаСостояния,
	|				СостоянияОСОрганизаций.Регистратор КАК ДокументУстановкиСостояния
	|			ИЗ
	|				РегистрСведений.СостоянияОСОрганизаций КАК СостоянияОСОрганизаций
	|			
	|			ГДЕ
	|				СостоянияОСОрганизаций.ДатаСостояния в 	(Выбрать максимум(ДатаСостояния)
	|					ИЗ
	|						РегистрСведений.СостоянияОСОрганизаций КАК ДатаПоследнегоСостояния
	|			
	|					ГДЕ
	|
	|				ДатаПоследнегоСостояния.Организация = &Организация и ДатаПоследнегоСостояния.ОсновноеСредство = СостоянияОСОрганизаций.ОсновноеСредство И
	|				(выбор когда &ДатаОкончания = &ПустаяДата тогда истина иначе ДатаПоследнегоСостояния.ДатаСостояния < &ДатаОкончания конец) сгруппировать по ДатаПоследнегоСостояния.ОсновноеСредство) и
	|				(СостоянияОСОрганизаций.НомерСтроки В (ВЫБРАТЬ РАЗЛИЧНЫЕ 	МАКСИМУМ(ДатаПоследнегоСостояния.НомерСтроки) ИЗ РегистрСведений.СостоянияОСОрганизаций КАК ДатаПоследнегоСостояния ГДЕ 	ДатаПоследнегоСостояния.Организация = &Организация И ДатаПоследнегоСостояния.ОсновноеСредство = СостоянияОСОрганизаций.ОсновноеСредство И ДатаПоследнегоСостояния.ДатаСостояния = СостоянияОСОрганизаций.ДатаСостояния СГРУППИРОВАТЬ ПО 	ДатаПоследнегоСостояния.ОсновноеСредство )) И
	|				СостоянияОСОрганизаций.Организация = &Организация ) КАК ТекущееСостояние
	|			ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ТекущееСостояние.ОсновноеСредство
	|		ПО НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.ОсновноеСредство = ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство
	|
	| {ГДЕ
	|	ВЫБОР КОГДА (СнятыеСУчета.СнятоСУчета) ЕСТЬ NULL  ТОГДА ЛОЖЬ ИНАЧЕ СнятыеСУчета.СнятоСУчета КОНЕЦ КАК ОССнятоСУчетаНаНачало,
	//|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.СписаноПриПринятииКУчету,
	|	СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетУчета,
	|	ТекущееСостояние.Состояние,
	|	СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних.СпособыОтраженияРасходовПоАмортизации,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.Местонахождение КАК Подразделение,
	|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ}
	|	
	|СГРУППИРОВАТЬ ПО
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство,
	|	СнятыеСУчета.СнятоСУчета,
	//|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.СписаноПриПринятииКУчету,
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.ОсновноеСредство.ПодлежитАмортизации,
	|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.СрокПолезногоИспользования,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.ОбъемПродукцииРаботДляВычисленияАмортизации,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентАмортизации,
	//|	ПараметрыАмортизацииОСБухгалтерскийУчетСрезПоследних.КоэффициентУскорения,
	//|	ГрафикиАмортизацииБухгалтерскийУчетСрезПоследних.ГрафикАмортизации,
	//|	СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетУчета,
	//|	СчетаБухгалтерскогоУчетаОсновныхСредствСрезПоследних.СчетНачисленияАмортизации,
	|	ПервоначальныеСведенияОбОсновныхСредствахОрганизацийСрезПоследних.МетодНачисленияАмортизации,
	//|	СпособыОтраженияРасходовПоАмортизацииОСБухгалтерскийУчетСрезПоследних.СпособыОтраженияРасходовПоАмортизации,
	|	ПринятиеКУчету.ДатаСостояния,
	|   МестонахождениеОСБухгалтерскийУчетСрезПоследних.Местонахождение,
	//|	МестонахождениеОСБухгалтерскийУчетСрезПоследних.МОЛ
	|	ТекущееСостояние.Состояние,
	//|	ТекущееСостояние.ДатаСостояния,
	|	НачислениеАмортизацииБухгалтерскийУчетСрезПоследних.НачислятьАмортизацию
	|
	|ИТОГИ СУММА(ПервоначальнаяСтоимость), СУММА(СтоимостьНачальныйОстаток), СУММА(АмортизацияНачальныйОстаток), СУММА(СтоимостьОборотДт), СУММА(СтоимостьОборотКт), СУММА(АмортизацияОборот), СУММА(СтоимостьКонечныйОстаток), СУММА(АмортизацияКонечныйОстаток), СУММА(ОстаточнаяСтоимость), СУММА(Выработка) ПО
	|	Подразделение,ОсновноеСредство
	//|	,СчетУчета,ОССнятоСУчетаНаНачало,  МОЛ
	|{ИТОГИ ПО
	|	Подразделение, МОЛ, ОсновноеСредство.*,СчетУчета,ОССнятоСУчетаНаНачало,ЗначениеТекущегоСостояния }";
	
	
	
	СтруктураПредставлениеПолей = Новый Структура;
	СтруктураПредставлениеПолей.Вставить( "ОсновноеСредство",       "Основное средство");
	СтруктураПредставлениеПолей.Вставить( "СписаноПриПринятииКУчету","Списано на затраты");
	СтруктураПредставлениеПолей.Вставить( "ОССнятоСУчетаНаНачало",   "Снято с учета на начало отчета");
	
	СтруктураПредставлениеПолей.Вставить( "ДатаПринятияКУчету",     "Дата принятия к учету");
	СтруктураПредставлениеПолей.Вставить( "ДатаПоследнегоСостояния","Дата установки текущего состояния");
	СтруктураПредставлениеПолей.Вставить( "ЗначениеТекущегоСостояния",     			"Текущее состояние");
	
	СтруктураПредставлениеПолей.Вставить( "СчетУчета", "Счет учета");
	СтруктураПредставлениеПолей.Вставить( "СчетНачисленияАмортизации", "Счет амортизации");
	
	СтруктураПредставлениеПолей.Вставить( "МетодНачисленияАмортизации",       "Способ начисления амортизации");
	СтруктураПредставлениеПолей.Вставить( "СпособыОтраженияРасходовПоАмортизации", "Отражение расходов");
	
	СтруктураПредставлениеПолей.Вставить( "СрокИспользованияДляВычисленияАмортизации", "Срок использования (для амортизации)");
	СтруктураПредставлениеПолей.Вставить( "ОбъемПродукцииРаботДляВычисленияАмортизации", "Объем продукции");
	СтруктураПредставлениеПолей.Вставить( "КоэффициентАмортизации", "Коэффициент амортизации");
	СтруктураПредставлениеПолей.Вставить( "КоэффициентУскорения",   "Коэффициент ускорения (для способа уменьшаемого остатака)");
	СтруктураПредставлениеПолей.Вставить( "ГрафикАмортизации", "Годовой график");
	
	
	ПостроительОтчета.Текст = Текст;
	 #Если Клиент Тогда
	УправлениеОтчетами.ЗаполнитьПредставленияПолей(СтруктураПредставлениеПолей, ПостроительОтчета);
	УправлениеОтчетами.ОчиститьДополнительныеПоляПостроителя(ПостроительОтчета);
	
	ОбщийОтчет.ЗаполнитьПоказатели( "ПервоначальнаяСтоимость",   "Первоначальная стоимость",    Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьДляВычисленияАмортизации",   "Стоимость для вычисления амортизации",    Истина, "ЧЦ=15; ЧДЦ=2");
	
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьНачальныйОстаток", "Стоимость на начало периода", Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "АмортизацияНачальныйОстаток", "Амортизация на начало периода", Истина, "ЧЦ=15; ЧДЦ=2");
	
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьОборотДт",           "Увеличение стоимости",         Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "АмортизацияОборот",           "Амортизация за период",         Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьОборотКт",           "Уменьшение стоимости",         Истина, "ЧЦ=15; ЧДЦ=2");
	
	ОбщийОтчет.ЗаполнитьПоказатели( "СтоимостьКонечныйОстаток",  "Стоимость на конец периода",  Истина, "ЧЦ=15; ЧДЦ=2");
	ОбщийОтчет.ЗаполнитьПоказатели( "АмортизацияКонечныйОстаток",  "Амортизация на конец периода",  Истина, "ЧЦ=15; ЧДЦ=2");
	
	ОбщийОтчет.ЗаполнитьПоказатели( "ОстаточнаяСтоимость",       "Остаточная стоимость",        Истина, "ЧЦ=15; ЧДЦ=2");
	
	МассивОтбора = Новый Массив;
	МассивОтбора.Добавить("ОсновноеСредство");
	МассивОтбора.Добавить("ОССнятоСУчетаНаНачало");
	
	УправлениеОтчетами.ЗаполнитьОтбор(МассивОтбора, ПостроительОтчета);
	 #КонецЕсли
КонецПроцедуры // ЗаполнитьНачальныеНастройки()

// Читает свойство Построитель отчета
//
// Параметры
//	Нет
//
Функция ПолучитьПостроительОтчета() Экспорт

	Возврат ОбщийОтчет.ПолучитьПостроительОтчета();

КонецФункции // ПолучитьПостроительОтчета()

// Настраивает отчет по переданной структуре параметров
//
// Параметры:
//	Нет.
//
Процедура Настроить(Параметры) Экспорт

	ОбщийОтчет.Настроить(Параметры, ЭтотОбъект);

КонецПроцедуры // Настроить()

// Возвращает основную форму отчета, связанную с данным экземпляром отчета
//
// Параметры
//	Нет
//
Функция ПолучитьОсновнуюФорму() Экспорт
	
	ОснФорма = ПолучитьФорму();
	ОснФорма.ОбщийОтчет = ОбщийОтчет;
	ОснФорма.ЭтотОтчет  = ЭтотОбъект;
	
	Возврат ОснФорма;
	
КонецФункции // ПолучитьОсновнуюФорму()

// Возвращает форму настройки 
//
// Параметры:
//	Нет.
//
// Возвращаемое значение:
//	
//
Функция ПолучитьФормуНастройки() Экспорт
	
	ФормаНастройки = ОбщийОтчет.ПолучитьФорму("ФормаНастройка");
	Возврат ФормаНастройки;
	
КонецФункции // ПолучитьФормуНастройки()

// Процедура обработки расшифровки
//
// Параметры:
//	Нет.
//
Процедура ОбработкаРасшифровки(РасшифровкаСтроки, ПолеТД, ВысотаЗаголовка, СтандартнаяОбработка) Экспорт
	
	// Добавление расшифровки из колонки
	Если ТипЗнч(РасшифровкаСтроки) = Тип("Структура") Тогда
		
		// Расшифровка колонки находится в заголовке колонки
		РасшифровкаКолонки = ПолеТД.Область(ВысотаЗаголовка+2, ПолеТД.ТекущаяОбласть.Лево).Расшифровка;

		Расшифровка = Новый Структура;

		Для каждого Элемент Из РасшифровкаСтроки Цикл
			Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
		КонецЦикла;

		Если ТипЗнч(РасшифровкаКолонки) = Тип("Структура") Тогда

			Для каждого Элемент Из РасшифровкаКолонки Цикл
				Расшифровка.Вставить(Элемент.Ключ, Элемент.Значение);
			КонецЦикла;

		КонецЕсли; 

		ОбщийОтчет.ОбработкаРасшифровкиСтандартногоОтчета(Расшифровка, СтандартнаяОбработка, ЭтотОбъект);

	КонецЕсли;
	
КонецПроцедуры // ОбработкаРасшифровки()

// Добавляет в структуру общие для всех отчетов параметры настройки
//
// Параметры:
//	Нет.
//
Функция СформироватьСтруктуруДляСохраненияНастроек(ПоказыватьЗаголовок) Экспорт
	
	СтруктураНастроек = Новый Структура;
	
	СтруктураНастроек.Вставить("НастройкиПостроителя", ОбщийОтчет.ПостроительОтчета.ПолучитьНастройки());
	СтруктураНастроек.Вставить("Показатели", ОбщийОтчет.Показатели.Выгрузить());
	СтруктураНастроек.Вставить("ВыводитьДополнительныеПоляВОтдельнойКолонке", ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке);
	СтруктураНастроек.Вставить("ВыводитьИтогиПоВсемУровням", ОбщийОтчет.ВыводитьИтогиПоВсемУровням);
	СтруктураНастроек.Вставить("ВыводитьПоказателиВСтроку", ОбщийОтчет.ВыводитьПоказателиВСтроку);
	СтруктураНастроек.Вставить("РаскрашиватьИзмерения", ОбщийОтчет.РаскрашиватьИзмерения);
	СтруктураНастроек.Вставить("ЗаголовокПомечен", ОбщийОтчет.ПоказыватьЗаголовок);
	
	Возврат СтруктураНастроек;
	
КонецФункции // СформироватьСтруктуруДляСохраненияНастроек()()

// Заполняет из структуры настроек общие параметры отчетов
//
// Параметры:
//	Нет.
//
Процедура ВосстановитьНастройкиИзСтруктуры(СтруктураСНастройками, ПоказыватьЗаголовок) Экспорт
	Перем ТабПоказатели;
	
	Если ТипЗнч(ОбщийОтчет.СохраненныеНастройки) <> Тип("Структура") Тогда
		Возврат;
	КонецЕсли;
	
	ОбщийОтчет.ПостроительОтчета.УстановитьНастройки(СтруктураСНастройками.НастройкиПостроителя);
	
	СтруктураСНастройками.Свойство("Показатели", ТабПоказатели);
	Если ТипЗнч(ТабПоказатели) = Тип("ТаблицаЗначений") Тогда
		ОбщийОтчет.Показатели.Загрузить(ТабПоказатели);
	КонецЕсли;
	
	СтруктураСНастройками.Свойство("ВыводитьДополнительныеПоляВОтдельнойКолонке", ОбщийОтчет.ВыводитьДополнительныеПоляВОтдельнойКолонке);
	СтруктураСНастройками.Свойство("ВыводитьИтогиПоВсемУровням", ОбщийОтчет.ВыводитьИтогиПоВсемУровням);
	СтруктураСНастройками.Свойство("ВыводитьПоказателиВСтроку", ОбщийОтчет.ВыводитьПоказателиВСтроку);
	СтруктураСНастройками.Свойство("РаскрашиватьИзмерения", ОбщийОтчет.РаскрашиватьИзмерения);
	СтруктураСНастройками.Свойство("ЗаголовокПомечен", ОбщийОтчет.ПоказыватьЗаголовок);
	
КонецПроцедуры // ВосстановитьНастройкиИзСтруктуры(СохраненныеНастройки)()

ОбщийОтчет.ИмяРегистра          = "СтоимостьОС";
ОбщийОтчет.мНазваниеОтчета      = "Ведомость по амортизации ОС";
ОбщийОтчет.мВыбиратьИмяРегистра = Ложь;
ОбщийОтчет.мРежимВводаПериода   = 0;