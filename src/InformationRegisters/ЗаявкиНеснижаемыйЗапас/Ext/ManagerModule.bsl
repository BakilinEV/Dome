
Процедура СформироватьОтчет(ДокументРезультат, НаДату=Неопределено, ОсновноеСредство=Неопределено, ОтобразитьОстатокЮралс=Истина) Экспорт
	
	Если НаДату = Неопределено Тогда
		НаДату = ТекущаяДата();
	КонецЕсли;
	
	Если ОтобразитьОстатокЮралс Тогда
		
		Параметры = Новый Структура("Дата", НаДату);
		
		Соединение = Новый HTTPСоединение("192.168.40.9",, "serv", "SERVgfhjkm");
		ЗапросHTTP = Новый HTTPЗапрос("/Urals_BUH/hs/invAPI/OSTPTK");
		ЗапросHTTP.УстановитьТелоИзСтроки(XMLСтрока(Новый ХранилищеЗначения(Параметры)));
		
		Результат = Соединение.ОтправитьДляОбработки(ЗапросHTTP);
		Если Результат.КодСостояния<>200 ТОгда
			Сообщить("Ошибка код: "+Результат.КодСостояния);
			Сообщить(Результат.ПолучитьТелоКакСтроку());
			ОтобразитьОстатокЮралс = Ложь;
		КонецЕсли;
		
		Массив = XMLЗначение(Тип("ХранилищеЗначения"),Результат.ПолучитьТелоКакСтроку()).Получить();
		ТаблицаОстатокЮралс = Массив[1];
		//ТаблицаОстатокЮралс.ВыбратьСтроку();
		
	КонецЕсли;
	
	ДокументРезультат.Очистить();
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура КАК Номенклатура
	|ПОМЕСТИТЬ СписокНоменклатуры
	|ИЗ
	|	РегистрСведений.ВысоковостребованныйНеснижаемыйЗапас КАК ВысоковостребованныйНеснижаемыйЗапас
	|ГДЕ
	|	(ВысоковостребованныйНеснижаемыйЗапас.ОсновноеСредство = &ОсновноеСредство
	|			ИЛИ &ОсновноеСредство = ЗНАЧЕНИЕ(Справочник.ОсновныеСредства.ПустаяСсылка)
	|			ИЛИ &ОсновноеСредство = НЕОПРЕДЕЛЕНО)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	МАКСИМУМ(НАЧАЛОПЕРИОДА(ХозрасчетныйОборотыДтКт.Период, ДЕНЬ)) КАК Период,
	|	ХозрасчетныйОборотыДтКт.СубконтоДт1 КАК Номенклатура
	|ПОМЕСТИТЬ ДатаПоследнегоПоступленияНоменклатуры
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(, &НаДату, Регистратор, СчетДт.Код = ""10.05"", , СчетКт.КодБыстрогоВыбора = ""6001"", , ) КАК ХозрасчетныйОборотыДтКт
	|ГДЕ
	|	ХозрасчетныйОборотыДтКт.СубконтоДт1 В
	|			(ВЫБРАТЬ
	|				СписокНоменклатуры.Номенклатура
	|			ИЗ
	|				СписокНоменклатуры)
	|
	|СГРУППИРОВАТЬ ПО
	|	ХозрасчетныйОборотыДтКт.СубконтоДт1
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ХозрасчетныйОборотыДтКт.СубконтоДт1 КАК Номенклатура,
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1 КАК Поставщик,
	|	ХозрасчетныйОборотыДтКт.КоличествоОборотДт КАК ПриходКоличество,
	|	ХозрасчетныйОборотыДтКт.СуммаНУОборотДт КАК ПриходСуммаБезНДС,
	|	ВЫБОР
	|		КОГДА ХозрасчетныйОборотыДтКт.КоличествоОборотДт = 0
	|			ТОГДА ХозрасчетныйОборотыДтКт.СуммаНУОборотДт
	|		ИНАЧЕ ХозрасчетныйОборотыДтКт.СуммаНУОборотДт / ХозрасчетныйОборотыДтКт.КоличествоОборотДт
	|	КОНЕЦ КАК ПриходЦенаБезНДС,
	|	ХозрасчетныйОборотыДтКт.СуммаНУОборотДт * 1.2 КАК ПриходСумма
	|ПОМЕСТИТЬ ДанныеПоступления
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(
	|			,
	|			&НаДату,
	|			Регистратор,
	|			СчетДт.Код = ""10.05"",
	|			,
	|			СчетКт.Код = ""60.01"",
	|			,
	|			СубконтоДт1 В
	|				(ВЫБРАТЬ
	|					СписокНоменклатуры.Номенклатура
	|				ИЗ
	|					СписокНоменклатуры)) КАК ХозрасчетныйОборотыДтКт
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДатаПоследнегоПоступленияНоменклатуры КАК ДатаПоследнегоПоступленияНоменклатуры
	|		ПО ХозрасчетныйОборотыДтКт.СубконтоДт1 = ДатаПоследнегоПоступленияНоменклатуры.Номенклатура
	|			И ХозрасчетныйОборотыДтКт.Период >= ДатаПоследнегоПоступленияНоменклатуры.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ХозрасчетныйОборотыДтКт.СубконтоКт1 КАК Номенклатура,
	|	ХозрасчетныйОборотыДтКт.КоличествоОборотКт КАК РасходКоличество,
	|	ХозрасчетныйОборотыДтКт.СуммаОборот КАК РасходСумма
	|ПОМЕСТИТЬ ДанныеРеализации
	|ИЗ
	|	РегистрБухгалтерии.Хозрасчетный.ОборотыДтКт(
	|			,
	|			&НаДату,
	|			Регистратор,
	|			СчетДт.Код = ""22"",
	|			,
	|			СчетКт.Код = ""10.05"",
	|			,
	|			СубконтоКт1 В
	|				(ВЫБРАТЬ
	|					СписокНоменклатуры.Номенклатура
	|				ИЗ
	|					СписокНоменклатуры)) КАК ХозрасчетныйОборотыДтКт
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ДатаПоследнегоПоступленияНоменклатуры КАК ДатаПоследнегоПоступленияНоменклатуры
	|		ПО ХозрасчетныйОборотыДтКт.СубконтоКт1 = ДатаПоследнегоПоступленияНоменклатуры.Номенклатура
	|			И ХозрасчетныйОборотыДтКт.Период >= ДатаПоследнегоПоступленияНоменклатуры.Период
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВысоковостребованныйНеснижаемыйЗапас.ОсновноеСредство КАК ОсновноеСредство,
	|	ВЫБОР
	|		КОГДА (ВЫРАЗИТЬ(ВысоковостребованныйНеснижаемыйЗапас.ОсновноеСредство.ЗаводскойНомер КАК СТРОКА(100))) = """"
	|			ТОГДА """"
	|		ИНАЧЕ ""VIN: "" + (ВЫРАЗИТЬ(ВысоковостребованныйНеснижаемыйЗапас.ОсновноеСредство.ЗаводскойНомер КАК СТРОКА(100)))
	|	КОНЕЦ КАК ЗаводскойНомер,
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура КАК Номенклатура,
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура.Код КАК КодЮралс,
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура.Артикул КАК КаталожныйНомер,
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура.БазоваяЕдиницаИзмерения КАК ЕдиницаИзмерения,
	|	ВысоковостребованныйНеснижаемыйЗапас.МинимальноеКоличество КАК МинимальноеКоличество,
	|	ДанныеПоступления.ПриходЦенаБезНДС КАК ПриходЦенаБезНДС,
	|	ДанныеПоступления.ПриходСуммаБезНДС КАК ПриходСуммаБезНДС,
	|	ДанныеПоступления.ПриходКоличество КАК ПриходКоличество,
	|	ДанныеПоступления.Поставщик КАК Поставщик,
	|	ДанныеПоступления.ПриходСумма КАК ПриходСумма,
	|	ДанныеРеализации.РасходКоличество КАК РасходКоличество,
	|	ДанныеРеализации.РасходСумма КАК РасходСумма,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.СуммаОстаток, 0) КАК ОстатокСумма,
	|	ЕСТЬNULL(ХозрасчетныйОстатки.КоличествоОстаток, 0) КАК ОстатокКоличество
	|ИЗ
	|	РегистрСведений.ВысоковостребованныйНеснижаемыйЗапас КАК ВысоковостребованныйНеснижаемыйЗапас
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДанныеПоступления КАК ДанныеПоступления
	|		ПО ВысоковостребованныйНеснижаемыйЗапас.Номенклатура = ДанныеПоступления.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ ДанныеРеализации КАК ДанныеРеализации
	|		ПО ВысоковостребованныйНеснижаемыйЗапас.Номенклатура = ДанныеРеализации.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрБухгалтерии.Хозрасчетный.Остатки(
	|				&НаДату,
	|				Счет.Код = ""10.05"",
	|				,
	|				Субконто1 В
	|					(ВЫБРАТЬ
	|						СписокНоменклатуры.Номенклатура
	|					ИЗ
	|						СписокНоменклатуры)) КАК ХозрасчетныйОстатки
	|		ПО ВысоковостребованныйНеснижаемыйЗапас.Номенклатура = ХозрасчетныйОстатки.Субконто1
	|ГДЕ
	|	(ВысоковостребованныйНеснижаемыйЗапас.ОсновноеСредство = &ОсновноеСредство
	|			ИЛИ &ОсновноеСредство = ЗНАЧЕНИЕ(Справочник.ОсновныеСредства.ПустаяСсылка)
	|			ИЛИ &ОсновноеСредство = НЕОПРЕДЕЛЕНО)
	|
	|УПОРЯДОЧИТЬ ПО
	|	ОсновноеСредство,
	|	ВысоковостребованныйНеснижаемыйЗапас.Номенклатура.Наименование
	|ИТОГИ
	|	СУММА(МинимальноеКоличество),
	|	СУММА(ПриходЦенаБезНДС),
	|	СУММА(ПриходСуммаБезНДС),
	|	СУММА(ПриходКоличество),
	|	МАКСИМУМ(Поставщик),
	|	СУММА(ПриходСумма),
	|	СУММА(РасходКоличество),
	|	СУММА(РасходСумма),
	|	СУММА(ОстатокСумма),
	|	СУММА(ОстатокКоличество)
	|ПО
	|	ОБЩИЕ,
	|	ОсновноеСредство,
	|	Номенклатура");
	
	Запрос.УстановитьПараметр("НаДату", НаДату);
	Запрос.УстановитьПараметр("ОсновноеСредство", ОсновноеСредство); 
	
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		Возврат;
	КонецЕсли;
	
	Макет = ПолучитьМакет("НеснижаемыйЗапас");
	
	ДокументРезультат.Вывести(Макет.ПолучитьОбласть("Шапка"));
	
	ОбластьИтог = Макет.ПолучитьОбласть("Итоги");
	
	ОбластьОС = Макет.ПолучитьОбласть("Группировка");
	ВыборкаОС = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "ОсновноеСредство");
	Пока ВыборкаОС.Следующий() Цикл
		
		ОбластьОС.Параметры.Заполнить(ВыборкаОС);
		ДокументРезультат.Вывести(ОбластьОС);
		
		НомерСтроки = 0;
		ВыборкаТМЦ = ВыборкаОС.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Номенклатура", "ОсновноеСредство");
		Пока ВыборкаТМЦ.Следующий() Цикл
			
			НомерСтроки = НомерСтроки+1;
			
			ОбластьТМЦ = Макет.ПолучитьОбласть("Строка"+?(ВыборкаТМЦ.ОстатокКоличество > ВыборкаТМЦ.МинимальноеКоличество, 0, 1));
			
			ОбластьТМЦ.Параметры.Заполнить(ВыборкаТМЦ);
			ОбластьТМЦ.Параметры.НомерСтроки = НомерСтроки;
			ОбластьТМЦ.Параметры.КодЮралс = СокрЛП(ВыборкаТМЦ.КодЮралс);
			
			Если ОтобразитьОстатокЮралс Тогда
				НайденныеСтроки = ТаблицаОстатокЮралс.Найти(ВыборкаТМЦ.КодЮралс, "Код");
				Если НайденныеСтроки = Неопределено Тогда
					Остаток = "х";
				Иначе
					Остаток = НайденныеСтроки.Количество;
				КонецЕсли;
				ОбластьТМЦ.Параметры.ОстатокЮралс = Остаток;
			КонецЕсли;
			
			ДокументРезультат.Вывести(ОбластьТМЦ);
			
		КонецЦикла;
		
		ОбластьИтог.Параметры.Заполнить(ВыборкаОС);
		ОбластьИтог.Параметры.НаименованиеИтогов = "Итого:";
		ДокументРезультат.Вывести(ОбластьИтог);
		
	КонецЦикла;
	
	ВыборкаОбщийИтог = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ВыборкаОбщийИтог.Следующий();
	
	ОбластьИтог.Параметры.Заполнить(ВыборкаОбщийИтог);
	ОбластьИтог.Параметры.НаименованиеИтогов = "Общие итоги:";
	ДокументРезультат.Вывести(ОбластьИтог);
	
	ДокументРезультат.ФиксацияСверху = Макет.ПолучитьОбласть("Шапка").ВысотаТаблицы;
	
КонецПроцедуры
