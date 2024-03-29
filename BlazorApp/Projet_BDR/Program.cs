using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Web;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Npgsql;
using Projet_BDR.Context;
using Projet_BDR.Data;
using Projet_BDR.Service;
using Projet_BDR.Pages;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();
builder.Services.AddDbContext<ValoContext>(options => options.UseNpgsql(builder.Configuration.GetConnectionString("Connection")));
builder.Services.AddServerSideBlazor();
builder.Services.AddScoped<TournoiService>();
builder.Services.AddScoped<EquipeService>();
builder.Services.AddScoped<JoueurService>();
builder.Services.AddScoped<PaysService>();
builder.Services.AddScoped<ArmeService>();
builder.Services.AddScoped<MatchService>();
builder.Services.AddScoped<MancheService>();
builder.Services.AddScoped<RoundService>();
builder.Services.AddScoped<CarteService>();
builder.Services.AddScoped<AgentService>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();
