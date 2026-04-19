const apiBase = '/.netlify/functions/api-proxy';
let monthChart = null;
let categoryChart = null;
let creditChart = null;

console.log('dashboard.js loaded');

// Formato de moeda para exibição
function formatarMoeda(valor) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL'
    }).format(valor || 0);
}

function normalizarItem(item) {
    if (!item || typeof item !== 'object') {
        return item;
    }
    const normalized = {};
    Object.keys(item).forEach(key => {
        normalized[key.toLowerCase()] = item[key];
    });
    return normalized;
}

function extrairItems(response) {
    if (!response) {
        return [];
    }
    let items = [];
    if (Array.isArray(response.items)) {
        items = response.items;
    } else if (Array.isArray(response.ITEMS)) {
        items = response.ITEMS;
    } else if (Array.isArray(response.p_cursor)) {
        console.log('Extracted items from p_cursor:', response.p_cursor);
        items = response.p_cursor;
    } else if (Array.isArray(response.P_CURSOR)) {
        console.log('Extracted items from P_CURSOR:', response.P_CURSOR);
        items = response.P_CURSOR;
    } else if (response.items && Array.isArray(response.items.items)) {
        items = response.items.items;
    } else if (response.items && Array.isArray(response.items.DATA)) {
        items = response.items.DATA;
    }
    return items.map(normalizarItem);
}



// Mostrar erro
function mostrarErro(mensagem) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = mensagem;
    errorDiv.style.display = 'block';
    setTimeout(() => {
        errorDiv.style.display = 'none';
    }, 5000);
}

// Obter parâmetros dos filtros
function obterFiltros() {
    const anoInicio = document.getElementById('anoInicio').value;
    const mesInicio = document.getElementById('mesInicio').value;
    const anoFim = document.getElementById('anoFim').value;
    const mesFim = document.getElementById('mesFim').value;
    const responsavel = document.getElementById('responsavel').value || null;

    // Criar datas para período completo (para funções que ainda usam dt_ini/dt_fim)
    const dataInicio = `${anoInicio}-${mesInicio}-01`;
    const ultimoDiaMes = new Date(anoFim, mesFim, 0).getDate();
    const dataFim = `${anoFim}-${mesFim}-${ultimoDiaMes}`;

    const dt_ini = dataInicio ? formatarDataParaOracle(dataInicio) : null;
    const dt_fim = dataFim ? formatarDataParaOracle(dataFim) : null;

    return {
        // Parâmetros para funções com ano/mês único
        p_dt_ano: anoFim,
        p_dt_mes: mesFim,
        // Parâmetros para funções com período (dt_ini/dt_fim)
        dt_ini: dt_ini,
        dt_fim: dt_fim,
        // Parâmetros comuns
        responsavel: responsavel
    };
}

// Formatar data para o formato esperado pela API Oracle (DD/MM/YYYY)
function formatarDataParaOracle(dataISO) {
    const [ano, mes, dia] = dataISO.split('-');
    return `${dia}/${mes}/${ano}`;
}

// Chamar API via proxy
async function chamarAPI(endpoint, params) {
    try {
        console.log('Calling API:', endpoint, params);
        const response = await fetch(apiBase, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                endpoint: endpoint,
                ...params
            })
        });

        const data = await response.json();
        console.log('API Response for', endpoint, ':', data);
        
        if (!response.ok || data.error) {
            throw new Error(data.message || data.error || 'Erro na API');
        }

        return data;
    } catch (error) {
        console.error('Erro ao chamar API:', error);
        mostrarErro('Erro ao carregar dados: ' + error.message);
        throw error;
    }
}

// Carregar dados por mês
async function carregarPorMes() {
    try {
        const loader = document.getElementById('monthChartLoading');
        loader.style.display = 'flex';
        
        const filtros = obterFiltros();
        const response = await chamarAPI('pkg_operacoes/GET_OPERACOES_BY_MONTH_P', {
            p_dt_ano: filtros.p_dt_ano,
            p_dt_mes: filtros.p_dt_mes,
            p_responsavel: filtros.responsavel
        });
        
        const items = extrairItems(response);
        
        // Agrupar por mês
        const mesesMap = {};
        items.forEach(item => {
            const mes = new Date(item.mes).toLocaleDateString('pt-BR', { month: 'short', year: '2-digit' });
            if (!mesesMap[mes]) {
                mesesMap[mes] = { debito: 0, credito: 0 };
            }
            const tipo = item.tipo_operacao || item.tipo_operacao;
            const valor = Number(item.total_valor || item.total_valor || 0);
            if (tipo === 'DÉBITO' || tipo === 'DEBITO') {
                mesesMap[mes].debito += valor;
            } else {
                mesesMap[mes].credito += valor;
            }
        });

        const meses = Object.keys(mesesMap).reverse();
        const debitos = meses.map(mes => mesesMap[mes].debito);
        const creditos = meses.map(mes => mesesMap[mes].credito);

        // Destruir gráfico anterior se existir
        if (monthChart) {
            monthChart.destroy();
        }

        const ctx = document.getElementById('monthChart').getContext('2d');
        monthChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: meses,
                datasets: [
                    {
                        label: 'Despesas',
                        data: debitos,
                        borderColor: '#dc3545',
                        backgroundColor: 'rgba(220, 53, 69, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    },
                    {
                        label: 'Receitas',
                        data: creditos,
                        borderColor: '#28a745',
                        backgroundColor: 'rgba(40, 167, 69, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: true,
                        labels: {
                            usePointStyle: true,
                            padding: 15
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'R$ ' + value.toLocaleString('pt-BR');
                            }
                        }
                    }
                }
            }
        });

        loader.style.display = 'none';
    } catch (error) {
        document.getElementById('monthChartLoading').style.display = 'none';
        console.error('Erro ao carregar dados por mês:', error);
    }
}

// Carregar dados por categoria
async function carregarPorCategoria() {
    try {
        const loader = document.getElementById('categoryChartLoading');
        loader.style.display = 'flex';
        
        const filtros = obterFiltros();
        const response = await chamarAPI('pkg_operacoes/GET_OPERACOES_BY_CATEGORY_P', {
            p_dt_ano: filtros.p_dt_ano,
            p_dt_mes: filtros.p_dt_mes,
            p_responsavel: filtros.responsavel
        });
        
        const items = extrairItems(response);
        
        // Agrupar por categoria (apenas débitos)
        const categoriasMap = {};
        items.forEach(item => {
            const tipo = item.tipo_operacao;
            if (tipo === 'DÉBITO' || tipo === 'DEBITO') {
                const categoria = item.nm_categoria || item.nm_categoria || 'Sem categoria';
                const valor = Number(item.total_valor || item.total_valor || 0);
                if (!categoriasMap[categoria]) {
                    categoriasMap[categoria] = 0;
                }
                categoriasMap[categoria] += valor;
            }
        });

        const categorias = Object.keys(categoriasMap);
        const valores = categorias.map(cat => categoriasMap[cat]);

        // Gerar cores
        const cores = gerarCores(categorias.length);

        // Destruir gráfico anterior se existir
        if (categoryChart) {
            categoryChart.destroy();
        }

        const ctx = document.getElementById('categoryChart').getContext('2d');
        categoryChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: categorias,
                datasets: [{
                    data: valores,
                    backgroundColor: cores,
                    borderColor: '#fff',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            usePointStyle: true,
                            padding: 15
                        }
                    },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return formatarMoeda(context.parsed);
                            }
                        }
                    }
                }
            }
        });

        loader.style.display = 'none';
    } catch (error) {
        document.getElementById('categoryChartLoading').style.display = 'none';
        console.error('Erro ao carregar dados por categoria:', error);
    }
}

// Carregar top categorias
async function carregarTopCategorias() {
    try {
        const loader = document.getElementById('topCategoriesLoading');
        const table = document.getElementById('topCategoriesTable');
        const tbody = document.getElementById('topCategoriesBody');
        
        loader.style.display = 'flex';
        table.style.display = 'none';

        const filtros = obterFiltros();
        const response = await chamarAPI('pkg_operacoes/GET_TOP_CATEGORIES_P', {
            p_dt_ano: filtros.p_dt_ano,
            p_dt_mes: filtros.p_dt_mes,
            p_responsavel: filtros.responsavel,
            p_limit: 10
        });

        const items = extrairItems(response);
        
        if (items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted">Nenhuma categoria encontrada</td></tr>';
        } else {
            tbody.innerHTML = items.map(item => {
                const categoria = item.nm_categoria || item.nm_categoria || 'Sem categoria';
                const valor = Number(item.total_valor || item.total_valor || 0);
                const totalOperacoes = item.total_operacoes || item.total_operacoes || 0;
                const percentual = item.percentual || item.percentual || 0;
                return `
                <tr>
                    <td>${categoria}</td>
                    <td class="text-end">${formatarMoeda(valor)}</td>
                    <td class="text-end">${totalOperacoes}</td>
                    <td class="text-end">
                        <span class="badge-percentage">${percentual}%</span>
                    </td>
                </tr>
            `;
            }).join('');
        }

        loader.style.display = 'none';
        table.style.display = 'table';
    } catch (error) {
        document.getElementById('topCategoriesLoading').style.display = 'none';
        console.error('Erro ao carregar top categorias:', error);
    }
}

// Gerar cores para gráfico
function gerarCores(quantidade) {
    const cores = [
        '#667eea', '#764ba2', '#f093fb', '#4facfe',
        '#00f2fe', '#43e97b', '#fa709a', '#fee140',
        '#30cfd0', '#330867', '#30cfd0', '#330867'
    ];
    
    const resultado = [];
    for (let i = 0; i < quantidade; i++) {
        resultado.push(cores[i % cores.length]);
    }
    return resultado;
}

// Carregar chart de CRÉDITO apenas
async function carregarChartCredito() {
    try {
        const loader = document.getElementById('creditChartLoading');
        loader.style.display = 'flex';
        
        const filtros = obterFiltros();
        const response = await chamarAPI('pkg_operacoes/GET_OPERACOES_BY_MONTH_P', {
            p_dt_ano: filtros.p_dt_ano,
            p_dt_mes: filtros.p_dt_mes,
            p_responsavel: filtros.responsavel
        });
        
        const items = extrairItems(response);
        
        const mesesMap = {};
        items.forEach(item => {
            if (item.tipo_operacao === 'CRÉDITO' || item.tipo_operacao === 'CREDITO' || item.tipo_operacao === 'Crédito') {
                const mes = new Date(item.mes).toLocaleDateString('pt-BR', { month: 'short', year: '2-digit' });
                if (!mesesMap[mes]) {
                    mesesMap[mes] = 0;
                }
                mesesMap[mes] += item.total_valor || item.total_valor;
            }
        });

        const meses = Object.keys(mesesMap).reverse();
        const valores = meses.map(mes => mesesMap[mes]);

        // Destruir gráfico anterior se existir
        if (creditChart) {
            creditChart.destroy();
        }

        const ctx = document.getElementById('creditChart').getContext('2d');
        creditChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: meses,
                datasets: [{
                    label: 'Receitas',
                    data: valores,
                    backgroundColor: '#28a745',
                    borderColor: '#1e7e34',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return 'R$ ' + value.toLocaleString('pt-BR');
                            }
                        }
                    }
                }
            }
        });

        loader.style.display = 'none';
    } catch (error) {
        document.getElementById('creditChartLoading').style.display = 'none';
        console.error('Erro ao carregar chart de crédito:', error);
    }
}

// Carregar tabela hierárquica por mês e categoria
async function carregarTabelaHierarquica() {
    try {
        const loader = document.getElementById('hierarchicalTableLoading');
        const wrapper = document.getElementById('hierarchicalTableWrapper');
        const tbody = document.getElementById('hierarchicalTableBody');
        const headerRow = document.getElementById('monthHeaderRow');
        
        loader.style.display = 'flex';
        wrapper.style.display = 'none';

        const filtros = obterFiltros();
        const response = await chamarAPI('pkg_operacoes/GET_OPERACOES_MONTHLY_DETAIL_P', {
            p_dt_ano: filtros.p_dt_ano,
            p_dt_mes: filtros.p_dt_mes,
            p_responsavel: filtros.responsavel
        });
        
        const items = extrairItems(response);
        
        // Agrupar por categoria, subcategoria e mês
        const dataMap = {};
        const mesesSet = new Set();
        
        items.forEach(item => {
            const categoria = item.nm_categoria || 'Sem categoria';
            const subcategoria = item.nm_sub_categoria || '(sem subcategoria)';
            const mes = new Date(item.mes).toLocaleDateString('pt-BR', { month: '2-digit/yy' });
            const tipo = item.tipo_operacao;
            
            mesesSet.add(mes);
            
            if (!dataMap[categoria]) {
                dataMap[categoria] = {};
            }
            if (!dataMap[categoria][subcategoria]) {
                dataMap[categoria][subcategoria] = {};
            }
            if (!dataMap[categoria][subcategoria][mes]) {
                dataMap[categoria][subcategoria][mes] = { debito: 0, credito: 0 };
            }
            
            const valor = Number(item.total_valor || 0);
            if (tipo === 'DÉBITO' || tipo === 'DEBITO') {
                dataMap[categoria][subcategoria][mes].debito += valor;
            } else {
                dataMap[categoria][subcategoria][mes].credito += valor;
            }
        });

        // Ordenar meses
        const meses = Array.from(mesesSet).sort();
        
        // Construir header com meses
        let headerHTML = '<th>Categoria / Subcategoria</th>';
        meses.forEach(mes => {
            headerHTML += `<th>${mes}</th>`;
        });
        headerHTML += '<th>Total</th>';
        headerRow.innerHTML = headerHTML;

        // Construir linhas da tabela
        let tableHTML = '';
        const categorias = Object.keys(dataMap).sort();
        
        categorias.forEach(categoria => {
            const subcategorias = Object.keys(dataMap[categoria]).sort();
            
            // Calcular total da categoria
            let totalCategoria = 0;
            const totaisPorMes = {};
            meses.forEach(mes => {
                totaisPorMes[mes] = 0;
            });
            
            subcategorias.forEach(subcategoria => {
                meses.forEach(mes => {
                    const valores = dataMap[categoria][subcategoria][mes];
                    const valor = valores.debito - valores.credito; // Débito negativo
                    totalCategoria += valor;
                    totaisPorMes[mes] += valor;
                });
            });

            // Row da categoria (expandível)
            tableHTML += `<tr class="category-row" onclick="toggleSubcategorias('${categoria}')">
                <td class="category-toggle">
                    <i class="fas fa-chevron-right" id="toggle-${categoria}"></i>
                    <strong>${categoria}</strong>
                </td>`;
            
            meses.forEach(mes => {
                const valor = totaisPorMes[mes];
                const classe = valor < 0 ? '' : 'positive';
                tableHTML += `<td class="month-value ${classe}">${formatarMoeda(valor)}</td>`;
            });
            tableHTML += `<td><strong>${formatarMoeda(totalCategoria)}</strong></td></tr>`;

            // Rows das subcategorias
            subcategorias.forEach(subcategoria => {
                let totalSubcategoria = 0;
                const subcatMeses = {};
                
                meses.forEach(mes => {
                    const valores = dataMap[categoria][subcategoria][mes];
                    const valor = valores.debito - valores.credito;
                    totalSubcategoria += valor;
                    subcatMeses[mes] = valor;
                });

                tableHTML += `<tr class="subcategory-row" data-category="${categoria}">
                    <td>${subcategoria}</td>`;
                
                meses.forEach(mes => {
                    const valor = subcatMeses[mes];
                    const classe = valor < 0 ? '' : 'positive';
                    tableHTML += `<td class="month-value ${classe}">${formatarMoeda(valor)}</td>`;
                });
                tableHTML += `<td><strong>${formatarMoeda(totalSubcategoria)}</strong></td></tr>`;
            });
        });

        tbody.innerHTML = tableHTML;
        
        loader.style.display = 'none';
        wrapper.style.display = 'block';
    } catch (error) {
        document.getElementById('hierarchicalTableLoading').style.display = 'none';
        console.error('Erro ao carregar tabela hierárquica:', error);
    }
}

// Toggle subcategorias
function toggleSubcategorias(categoria) {
    const toggle = document.getElementById(`toggle-${categoria}`);
    const subcategorias = document.querySelectorAll(`tr[data-category="${categoria}"]`);
    
    toggle.classList.toggle('fa-chevron-right');
    toggle.classList.toggle('fa-chevron-down');
    
    subcategorias.forEach(row => {
        row.classList.toggle('visible');
    });
}

// Função principal de carregamento
async function carregarDashboard() {
    try {
        await Promise.all([
            carregarPorMes(),
            carregarPorCategoria(),
            carregarChartCredito(),
            carregarTabelaHierarquica(),
            carregarTopCategorias()
        ]);
    } catch (error) {
        console.error('Erro ao carregar dashboard:', error);
    }
}

// Adicionar listeners aos filtros
document.addEventListener('DOMContentLoaded', function() {
    // Carrega automaticamente ao alterar filtros
    ['anoInicio', 'mesInicio', 'anoFim', 'mesFim', 'responsavel'].forEach(id => {
        const element = document.getElementById(id);
        if (element) {
            element.addEventListener('change', () => {
                // Debounce de 500ms
                clearTimeout(window.filterTimeout);
                window.filterTimeout = setTimeout(carregarDashboard, 500);
            });
        }
    });
});
